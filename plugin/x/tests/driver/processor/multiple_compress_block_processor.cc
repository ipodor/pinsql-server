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

#include "plugin/x/tests/driver/processor/multiple_compress_block_processor.h"

#include <iostream>
#include <memory>
#include <stack>
#include <utility>
#include <vector>

#include "my_dbug.h"

#include "plugin/x/tests/driver/common/utils_mysql_parsing.h"
#include "plugin/x/tests/driver/connector/result_fetcher.h"
#include "plugin/x/tests/driver/connector/warning.h"
#include "plugin/x/tests/driver/processor/variable_names.h"

Block_processor::Result Multiple_compress_block_processor::feed(
    std::istream &input, const char *linebuf) {
  if (m_processing) {
    if (strcmp(linebuf, "-->end_compress") == 0) {
      auto xproto = m_context->m_connection->active_xprotocol();

      if (m_msg_id.empty()) {
        m_context->print_error(m_context->m_script_stack,
                               "No message found, this compression-block ",
                               "requires at least one message \n");
        return Result::Indigestion;
      }

      xcl::XError error;
      if (m_compress_style == xcl::Compression_style::k_multiple) {
        std::vector<xcl::XProtocol::Message *> messages;
        const auto first_id = m_msg_id.front();

        for (const auto id : m_msg_id) {
          if (first_id != id) {
            m_context->print_error(
                m_context->m_script_stack,
                "User tries to send multiple messages of different type, ",
                "MULTIPLE block must contain messages of the same type.\n");

            return Result::Indigestion;
          }
        }

        for (auto &m : m_messages) {
          messages.push_back(m.get());
        }

        error = xproto->send_compressed_frames(first_id, messages);
      } else if (m_compress_style == xcl::Compression_style::k_group) {
        std::vector<std::pair<Client_message_id, xcl::XProtocol::Message *>>
            group_messages;
        auto id = m_msg_id.begin();

        for (auto &m : m_messages) {
          group_messages.push_back({*id, m.get()});
          ++id;
        }

        error = xproto->send_compressed_group_of_frames(group_messages);
      } else if (m_compress_style == xcl::Compression_style::k_single) {
        auto id = m_msg_id.begin();
        for (auto &m : m_messages) {
          error = xproto->send_compressed_frame(*id, *m.get());

          if (error) break;

          ++id;
        }
      }

      m_messages.clear();
      m_msg_id.clear();

      if (error) {
        if (!m_context->m_expected_error.check_error(error))
          return Result::Indigestion;
      }
      m_processing = false;

      return Result::Eaten_but_not_hungry;
    }

    if (Result::Indigestion == m_message_processor.feed(input, linebuf))
      return Result::Indigestion;

    return Result::Feed_more;
  }

  if (strstr(linebuf, "-->begin_compress ") != linebuf)
    return Result::Not_hungry;

  std::string cmd = linebuf;
  m_context->m_variables->replace(&cmd);

  if (cmd.find("-->begin_compress SINGLE") == 0) {
    m_processing = true;
    m_compress_style = xcl::Compression_style::k_single;

    return Result::Feed_more;
  }

  if (cmd.find("-->begin_compress MULTIPLE") == 0) {
    m_processing = true;
    m_compress_style = xcl::Compression_style::k_multiple;

    return Result::Feed_more;
  }

  if (cmd.find("-->begin_compress GROUP") == 0) {
    m_processing = true;
    m_compress_style = xcl::Compression_style::k_group;

    return Result::Feed_more;
  }

  return Result::Not_hungry;
}

bool Multiple_compress_block_processor::feed_ended_is_state_ok() {
  if (!m_processing) return true;

  m_context->print_error(
      m_context->m_script_stack,
      "Unclosed -->begin_compress_same_messages directive\n");

  return false;
}

int Multiple_compress_block_processor::process(
    const xcl::XProtocol::Client_message_type_id message_id,
    const xcl::XProtocol::Message &message) {
  DBUG_TRACE;
  auto duplicated_message = message.New();
  duplicated_message->CopyFrom(message);

  m_msg_id.emplace_back(message_id);
  m_messages.emplace_back(duplicated_message);

  return 0;
}
