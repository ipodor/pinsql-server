/* Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   51 Franklin Street, Suite 500, Boston, MA 02110-1335 USA */

#ifndef BINLOG_OSTREAM_INCLUDED
#define BINLOG_OSTREAM_INCLUDED

#include "sql/basic_ostream.h"

/**
   Copy data from an input stream to an output stream.

   @param[in] istream   the input stream where data will be copied from
   @param[out] ostream  the output stream where data will be copied into
   @param[out] ostream_error It will be set to true if an error happens on
                             ostream and the pointer is not null. It is valid
                             only when the function returns true.

   @retval false Success
   @retval true Error happens in either the istream or ostream.
*/
template <class ISTREAM, class OSTREAM>
bool stream_copy(ISTREAM *istream, OSTREAM *ostream,
                 bool *ostream_error = nullptr) {
  unsigned char *buffer = nullptr;
  my_off_t length = 0;

  bool ret = istream->begin(&buffer, &length);
  while (!ret && length > 0) {
    if (ostream->write(buffer, length)) {
      if (ostream_error != nullptr) *ostream_error = true;
      return true;
    }

    ret = istream->next(&buffer, &length);
  }
  return ret;
}

/**
   A binlog cache implementation based on IO_CACHE.
*/
class IO_CACHE_binlog_cache_storage : public Truncatable_ostream {
 public:
  IO_CACHE_binlog_cache_storage();
  IO_CACHE_binlog_cache_storage &operator=(
      const IO_CACHE_binlog_cache_storage &) = delete;
  IO_CACHE_binlog_cache_storage(const IO_CACHE_binlog_cache_storage &) = delete;
  ~IO_CACHE_binlog_cache_storage();

  /**
     Opens the binlog cache. It creates a memory buffer as long as cache_size.
     The buffer will be extended up to max_cache_size when writting data. The
     data exceeds max_cache_size will be writting into temporary file.

     @param[in] dir  Where the temporary file will be created
     @param[in] prefix  Prefix of the temporary file name
     @param[in] cache_size  Size of the memory buffer.
     @param[in] max_cache_size  Maximum size of the memory buffer
     @retval false  Success
     @retval true  Error
  */
  bool open(const char *dir, const char *prefix, my_off_t cache_size,
            my_off_t max_cache_size);
  void close();

  bool write(const unsigned char *buffer, my_off_t length) override;
  bool truncate(my_off_t offset) override;
  /* purecov: inspected */
  /* binlog cache doesn't need seek operation. Setting true to return error */
  bool seek(my_off_t offset MY_ATTRIBUTE((unused))) override { return true; }

  my_off_t position() const noexcept override;

  /**
     Reset status and drop all data. It looks like a cache never was used after
     reset.
  */
  bool reset();
  /**
     Returns the file name if a temporary file is opened, otherwise nullptr is
     returned.
  */
  const char *tmp_file_name() const;
  /**
     Returns the count of calling temporary file's write()
  */
  size_t disk_writes() const;

  /**
     Initializes binlog cache for reading and returns the data at the begin.
     buffer is controlled by binlog cache implementation, so caller should
     not release it. If the function sets *length to 0 and no error happens,
     it has reached the end of the cache.

     @param[out] buffer  It points to buffer where data is read.
     @param[out] length  Length of the data in the buffer.
     @retval false  Success
     @retval true  Error
  */
  bool begin(unsigned char **buffer, my_off_t *length);
  /**
     Returns next piece of data. buffer is controlled by binlog cache
     implementation, so caller should not release it. If the function sets
     *length to 0 and no error happens, it has reached the end of the cache.

     @param[out] buffer  It points to buffer where data is read.
     @param[out] length  Length of the data in the buffer.
     @retval false  Success
     @retval true  Error
  */
  bool next(unsigned char **buffer, my_off_t *length);
  my_off_t length() const;

 private:
  IO_CACHE m_io_cache;
  my_off_t m_max_cache_size = 0;
};

/**
   Byte container that provides a storage for serializing session
   binlog events. This way of arranging the classes separates storage layer
   and binlog layer, hides the implementation detail of low level storage.
*/
class Binlog_cache_storage : public Basic_ostream {
 public:
  ~Binlog_cache_storage();

  bool open(my_off_t cache_size, my_off_t max_cache_size);
  void close();

  bool write(const unsigned char *buffer, my_off_t length) override {
    DBUG_ASSERT(m_pipeline_head != nullptr);
    return m_pipeline_head->write(buffer, length);
  }
  /**
     Truncates some data at the end of the binlog cache.

     @param[in] offset  Where the binlog cache will be truncated to.
     @retval false  Success
     @retval true  Error
  */
  bool truncate(my_off_t offset) { return m_pipeline_head->truncate(offset); }

  my_off_t position() const noexcept override {
    return m_pipeline_head->position();
  };

  /**
     Reset status and drop all data. It looks like a cache was never used
     after reset.
  */
  bool reset() { return m_file.reset(); }
  /**
     Returns the count of disk writes
  */
  size_t disk_writes() const { return m_file.disk_writes(); }
  /**
     Returns the name of the temporary file.
  */
  const char *tmp_file_name() const { return m_file.tmp_file_name(); }

  /**
     Copy all data to a output stream. This function hides the internal
     implementation of storage detail. So it will not disturb the callers
     if the implementation of Binlog_cache_storage is changed. If we add
     a pipeline stream in this class, then we need to change the implementation
     of this function. But callers are not affected.

     @param[out] ostream Where the data will be copied into
     @param[out] ostream_error It will be set to true if an error happens on
                               ostream and the pointer is not null. It is valid
                               only when the function returns true.
     @retval false  Success
     @retval true  Error happens in either the istream or ostream.
  */
  bool copy_to(Basic_ostream *ostream, bool *ostream_error = nullptr) {
    return stream_copy(&m_file, ostream, ostream_error);
  }

  /**
     Returns data length.
  */
  my_off_t length() const { return m_file.length(); }
  /**
     Returns true if binlog cache is empty.
  */
  bool is_empty() const { return length() == 0; }

 private:
  Truncatable_ostream *m_pipeline_head = nullptr;
  IO_CACHE_binlog_cache_storage m_file;
};

#endif  // BINLOG_OSTREAM_INCLUDED
