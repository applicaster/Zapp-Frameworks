/**
 * Copyright 2004-2017 Agama Technologies AB
 */

#ifndef EMP_COMM_KVS_H
#define EMP_COMM_KVS_H

#include "emp_communication.h"

#ifdef __cplusplus
extern "C"
{
#endif

  /**
   * This header file specifies the signature and semantics of the public
   * interface exported by EMP KVS module.
   */

  /** Internal handle for the KVS structure */
  typedef void* emp_kvs_handle;

  /**
   * Create a new KVS object based on the specified schema.
   *
   * @param schema name Name of the schema used.
   * @return emp_kvs_handle or NULL if initialisation was unsuccessful.
   */
  emp_kvs_handle empcomm_kvs_new(const char* schema_name);

  /**
   * Destroy emp_kvs_handle object and free its resources.
   *
   * @param kvs The emp kvs handle
   */
  void empcomm_kvs_free(emp_kvs_handle kvs);


  /**
   * Set or overwrite the previous value for various data types.
   *
   * @param kvs The emp kvs handle
   * @param path A valid jsonPath described by the schema
   * @param value Value set to the specified path
   *
   * @return 0 if Ok and -1 otherwise
   */
  int empcomm_kvs_set_text(emp_kvs_handle kvs, const char* path, const char* value);
  int empcomm_kvs_set_integer(emp_kvs_handle kvs, const char* path, int64_t value);
  int empcomm_kvs_set_double(emp_kvs_handle kvs, const char* path, double value);
  int empcomm_kvs_set_bool(emp_kvs_handle kvs, const char* path, uint8_t value);
  int empcomm_kvs_set_null(emp_kvs_handle kvs, const char* path);

  /**
   * Remove the value associated with the specified path.
   *
   * @param kvs The emp kvs handle
   * @param path A valid jsonPath described by the schema
   *
   * @return 0 if Ok and -1 otherwise
   */
  int empcomm_kvs_remove(emp_kvs_handle kvs, const char* path);

  /**
   * Set Probe Metadata with content of the KVS object.
   *
   * Note: It is safe to free the KVS object after calling this function.
   * @see emp_kvs_free
   *
   * @param emp_handle the EMP Client handle
   * @param type of probe metadata
   * @param kvs the emp kvs handle
   *
   * @return 0 if Ok and -1 otherwise
   */
  int empcomm_kvs_set_probe_metadata_from_kvs(emp_client_handle emp_handle,
                                              probe_metadata_t type,
                                              emp_kvs_handle kvs);

  /**
   * Set Session (state) Metadata with content of the KVS object.
   *
   * Note: It is safe to free the KVS object after calling this function.
   * @see emp_kvs_free
   *
   * @param emp_handle The EMP Client handle
   * @param type Type of state metadata
   * @param kvs The emp kvs handle
   *
   * @return 0 if Ok and -1 otherwise
   */
  int empcomm_kvs_set_state_metadata_from_kvs(emp_client_handle emp_handle,
                                              state_metadata_t type,
                                              emp_kvs_handle kvs);

#ifdef __cplusplus
}
#endif

#endif /* EMP_KVS_H */

