/**
 * Copyright Agama Technologies AB 2004-2016
 */


#ifndef __EMP_DEPRECATED__
#define __EMP_DEPRECATED__

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#ifndef _iOS_
#include "empclient_types.h"
#else
#include <empclient_types.h>
#endif
  int empcomm_idle_session(emp_client_handle emp_handle);
  int empcomm_dynamic_streaming_session(emp_client_handle emp_handle, const char* uri,
                                        ds_protocol_id_t protocol, view_state_id_t initial_view_state);
  int empcomm_extended_dynamic_streaming_session(emp_client_handle emp_handle, const char* uri,
                                                 ds_protocol_id_t protocol, const char* asset,
                                                 ds_playlist_type_t playlist_type,
                                                 view_state_id_t initial_view_state);
  int empcomm_set_state_metadata(emp_client_handle emp_handle,
                                 const state_metadata_value_t* value);
  int empcomm_set_probe_metadata(emp_client_handle emp_handle,
                                 const probe_metadata_value_t* value);
  int empcomm_dtv_session(emp_client_handle emp_handle,
                          const dtv_identification_t* service_info);

  typedef emp_client_handle session_t;

  inline session_t empcomm_open_session()
  {
    return empcomm_get_handle();
  }

  inline int empcomm_close_session(session_t session)
  {
    return empcomm_destroy_handle(session);
  }

#ifdef __cplusplus
}
#endif

#endif
