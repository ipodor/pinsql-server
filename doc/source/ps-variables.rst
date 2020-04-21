.. _ps_variables:

====================================================
 List of variables introduced in Percona Server 5.7
====================================================

System Variables
================

.. tabularcolumns:: |p{8.5cm}|p{1.5cm}|p{1.5cm}|p{2cm}|p{1.5cm}|

.. list-table::
   :header-rows: 1

   * - Name
     - Cmd-Line
     - Option File
     - Var Scope
     - Dynamic
   * - :variable:`audit_log_buffer_size`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_file`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_flush`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`audit_log_format`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_handler`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_policy`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`audit_log_rotate_on_size`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_rotations`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_strategy`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_syslog_facility`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_syslog_ident`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`audit_log_syslog_priority`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`binlog_space_limit`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`csv_mode`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`encrypt_binlog`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`encrypt-tmp-files`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`enforce_storage_engine`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`expand_fast_index_creation`
     - Yes
     - No
     - Both
     - Yes
   * - :variable:`extra_max_connections`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`extra_port`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`ft_query_extra_word_chars`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`have_backup_locks`
     - Yes
     - No
     - Global
     - No
   * - :variable:`have_backup_safe_binlog_info`
     - Yes
     - No
     - Global
     - No
   * - :variable:`have_snapshot_cloning`
     - Yes
     - No
     - Global
     - No
   * - :variable:`innodb_background_scrub_data_compressed`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_background_scrub_data_uncompressed`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_cleaner_lsn_age_factor`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_corrupt_table_action`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_default_encryption_key_id`
     - Yes
     - Yes
     - Session
     - Yes
   * - :variable:`innodb_empty_free_list_algorithm`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_encrypt_online_alter_logs`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_encrypt_tables`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_kill_idle_transaction`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_max_bitmap_file_size`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_max_changed_pages`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_online_encryption_rotate_key_age`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_online_encryption_threads`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_parallel_dblwr_encrypt`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_print_lock_wait_timeout_info`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_redo_log_encrypt`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_scrub_log`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_scrub_log_speed`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_show_locks_held`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_show_verbose_locks`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_sys_tablespace_encrypt`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`innodb_temp_tablespace_encrypt`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`innodb_track_changed_pages`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`innodb_undo_log_encrypt`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`innodb_use_global_flush_log_at_trx_commit`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`keyring_vault_config`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`keyring_vault_timeout`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`log_slow_filter`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`log_slow_rate_limit`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`log_slow_rate_type`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`log_slow_sp_statements`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`log_slow_verbosity`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`log_warnings_suppress`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`max_binlog_files`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`max_slowlog_files`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`max_slowlog_size`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`proxy_protocol_networks`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`pseudo_server_id`
     - Yes
     - No
     - Session
     - Yes
   * - :variable:`query_cache_strip_comments`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`query_response_time_flush`
     - Yes
     - No
     - Global
     - No
   * - :variable:`query_response_time_range_base`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`query_response_time_stats`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`slow_query_log_always_write_time`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`slow_query_log_use_global_control`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`thread_pool_high_prio_mode`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`thread_pool_high_prio_tickets`
     - Yes
     - Yes
     - Both
     - Yes
   * - :variable:`thread_pool_idle_timeout`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`thread_pool_max_threads`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`thread_pool_oversubscribe`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`thread_pool_size`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`thread_pool_stall_limit`
     - Yes
     - Yes
     - Global
     - No
   * - :variable:`thread_statistics`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`userstat`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`version_comment`
     - Yes
     - Yes
     - Global
     - Yes
   * - :variable:`version_suffix`
     - Yes
     - Yes
     - Global
     - Yes

Status Variables
================

.. tabularcolumns:: |p{13cm}|p{1.5cm}|p{1.5cm}|

.. list-table::
   :header-rows: 1

   * - Name
     - Var Type
     - Var Scope
   * - :variable:`Binlog_snapshot_file`
     - String
     - Global
   * - :variable:`Binlog_snapshot_position`
     - Numeric
     - Global
   * - :variable:`Com_lock_binlog_for_backup`
     - Numeric
     - Both
   * - :variable:`Com_lock_tables_for_backup`
     - Numeric
     - Both
   * - :variable:`Com_show_client_statistics`
     - Numeric
     - Both
   * - :variable:`Com_show_index_statistics`
     - Numeric
     - Both
   * - :variable:`Com_show_table_statistics`
     - Numeric
     - Both
   * - :variable:`Com_show_thread_statistics`
     - Numeric
     - Both
   * - :variable:`Com_show_user_statistics`
     - Numeric
     - Both
   * - :variable:`Com_unlock_binlog`
     - Numeric
     - Both
   * - :variable:`Innodb_background_log_sync`
     - Numeric
     - Global
   * - :variable:`Innodb_buffer_pool_pages_LRU_flushed`
     - Numeric
     - Global
   * - :variable:`Innodb_buffer_pool_pages_made_not_young`
     - Numeric
     - Global
   * - :variable:`Innodb_buffer_pool_pages_made_young`
     - Numeric
     - Global
   * - :variable:`Innodb_buffer_pool_pages_old`
     - Numeric
     - Global
   * - :variable:`Innodb_checkpoint_age`
     - Numeric
     - Global
   * - :variable:`Innodb_checkpoint_max_age`
     - Numeric
     - Global
   * - :variable:`Innodb_ibuf_free_list`
     - Numeric
     - Global
   * - :variable:`Innodb_ibuf_segment_size`
     - Numeric
     - Global
   * - :variable:`Innodb_lsn_current`
     - Numeric
     - Global
   * - :variable:`Innodb_lsn_flushed`
     - Numeric
     - Global
   * - :variable:`Innodb_lsn_last_checkpoint`
     - Numeric
     - Global
   * - :variable:`Innodb_master_thread_active_loops`
     - Numeric
     - Global
   * - :variable:`Innodb_master_thread_idle_loops`
     - Numeric
     - Global
   * - :variable:`Innodb_max_trx_id`
     - Numeric
     - Global
   * - :variable:`Innodb_mem_adaptive_hash`
     - Numeric
     - Global
   * - :variable:`Innodb_mem_dictionary`
     - Numeric
     - Global
   * - :variable:`Innodb_oldest_view_low_limit_trx_id`
     - Numeric
     - Global
   * - :variable:`Innodb_purge_trx_id`
     - Numeric
     - Global
   * - :variable:`Innodb_purge_undo_no`
     - Numeric
     - Global
   * - :variable:`Threadpool_idle_threads`
     - Numeric
     - Global
   * - :variable:`Threadpool_threads`
     - Numeric
     - Global
