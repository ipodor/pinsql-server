/*
 * Copyright (c) 2019, Oracle and/or its affiliates. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License, version 2.0,
 * as published by the Free Software Foundation.
 *
 * This program is also distributed with certain software (including
 * but not limited to OpenSSL) that is licensed under separate terms,
 * as designated in a particular file or component or in included license
 * documentation.  The authors of MySQL hereby grant you an additional
 * permission to link the program and your derivative works with the
 * separately licensed software that they have included with MySQL.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License, version 2.0, for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
 */

// MySQL DB access module, for use by plugins and others
// For the module that implements interactive DB functionality see mod_db

#ifndef PLUGIN_X_CLIENT_XCOMPRESSION_IMPL_H_
#define PLUGIN_X_CLIENT_XCOMPRESSION_IMPL_H_

#include <memory>
#include <set>

#include "plugin/x/client/mysqlxclient/xcompression.h"
#include "plugin/x/protocol/stream/compression/compression_algorithm_interface.h"
#include "plugin/x/protocol/stream/compression/decompression_algorithm_interface.h"

namespace xcl {

class Compression_impl : public XCompression {
 public:
  bool reinitialize(const Compression_algorithm algorithm,
                    const std::set<Compression_style> &uplink_style,
                    const std::set<Compression_style> &downlink_style) override;

  Input_stream_ptr downlink(Input_stream *data_stream) override;
  Output_stream_ptr uplink(Output_stream *data_stream) override;

 private:
  std::shared_ptr<protocol::Decompression_algorithm_interface>
      m_downlink_stream;
  std::shared_ptr<protocol::Compression_algorithm_interface> m_uplink_stream;
};

}  // namespace xcl

#endif  // PLUGIN_X_CLIENT_XCOMPRESSION_IMPL_H_
