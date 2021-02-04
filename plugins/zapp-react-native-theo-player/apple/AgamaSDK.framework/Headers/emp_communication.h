/**
 * Copyright 2004-2017 Agama Technologies AB
 */

#ifndef __EMP_COMM__
#define __EMP_COMM__
#define __STDC_LIMIT_MACROS

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#ifndef _iOS_
#include "empclient_types.h"
#include "stdbool.h"
#else
#include <empclient_types.h>
#endif

  #define EMPCOMM_LOG_FATAL    0
  #define EMPCOMM_LOG_ERROR    1
  #define EMPCOMM_LOG_WARNING  2
  #define EMPCOMM_LOG_INFO     3
  #define EMPCOMM_LOG_DEBUG    4
  #define EMPCOMM_LOG_INTERNAL 5

  /**
   * Unique EMP handle associated with current open EMP Client connection. Creating and
   * opening a handle if performed using empcomm_get_handle() function
   */
  typedef void* emp_client_handle;

  /**
   * Initialise resources used by the client library itself.
   *
   * Must be called before using any of the other library functions!
   *
   * @param verbose is currently not used. Set to EMPCOMM_LOG_FATAL for
   * the least verbose output.
   */
  void empcomm_init(int verbose);

  /**
   * Free up resources used by the client library itself.
   */
  void empcomm_free(void);

  /**
   * Open a communication handle to the Agama EMP client process.
   *
   * This is the first function to be called after empcomm_init().
   *
   * It is possible to connect to the same Agama EMP client
   * process from several different processes. They will share the same
   * EMP handle.
   *
   * @returns emp_client_handle, 0 on failure.
   */
  emp_client_handle empcomm_get_handle(void);


  /**
   * This function is used to retrieve the actual handle status, that is if it is still valid.
   * As the solution is using a separate EMP client process it is always a possibility that
   * this process dies from unknown reasons. And even if the process itself is restarted it
   * will still need a re-opening of a handle and external and device configuration in order to
   * work properly.
   *
   * The suggested approach is that the integrator regularly (at least once every 10s) calls this
   * function in order to determine if re-init is needed and if so perform a opening of a handle
   * and setting the proper external and device configuration
   *
   * @param emp_handle  the current EMP Client handle.
   * @param status  current handle status after call to this function.
   *
   * @returns
   *  0 if Ok and -1 In case of RPC communication error.
   *
   * Returns in the out-parameter status
   * - 0 If handle is Ok
   * - 1 If handle needs re-init
   * - 2 If handle is OK but a call to empcomm_set_external_config() is needed.
   */
  int empcomm_get_status(emp_client_handle emp_handle, int* status);


  /**
   * The destructor function that destroys the specific handle. As described for empcomm_get_handle()
   * currently all instances are sharing the same handle this mean that one should ONLY call this
   * function from one of the instances otherwise the handle will be closed for others as-well.
   *
   * @returns 0 if Ok and -1 in case of communication error.
   */
  int empcomm_destroy_handle(emp_client_handle emp_handle);


  /**
   * After the call dest_string is a string of type: VER:1.0-DATE:xxx-PROTOCOL_VER:4
   *
   * Were VER expresses the version of EMP client, DATE expresses the build date of EMP client
   * and PROTOCOL_VER expresses the implemented version of the EMP protocol.
   *
   * @returns 0 if Ok and -1 in case of communication error.
   */
  int empcomm_get_version_information(emp_client_handle emp_handle, char *dest_string, int string_length);


  /**
   * Set External configuration
   *
   * @param emp_handle the EMP Client handle.
   * @param config_string configuration string provided to the agama client.
   * @param result
   * returns the configuration result in out parameter result
   *
   * success: if the configuration string was successfully parsed and applied.
   * option_too_big: if the provided value for an option is too big, probably caused by some missing ";".
   * syntactic_error: if there is at least one syntactic error in the configuration string.
   * unknown_option: if at least one option name in the configuration string is unknown.
   * invalid_operator_id: the operator ID provided in the configuration string is not a valid operator ID.
   * invalid_error_holdoff_time: the error holdoff time must be between 0 and 255 seconds.
   * invalid_err_ms_mask: should be a 16 character hexadecimal integer with an optional 0x prefix.
   * invalid_zap_time: should be between 0 and 60 seconds. 0 means no zapping sessions will be generated.
   * invalid_idle_time_limit: should be between 0 and 60 seconds. 0 means that no IDLE state filtering will be done.
   * invalid_report_interval: should be 60, 120 or 240 seconds.
   *
   * @returns 0 on Ok and -1 on communication error
   *
   */
  int empcomm_set_external_config(emp_client_handle emp_handle, const char* config_string,
                                  config_result_t *result);


  /**
   * Set Device Metadata.
   *
   * @param emp_handle the EMP Client handle
   * @param value the value of the metadata
   *
   * @see device_metadata_t, device_metadata_value_t
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_set_device_metadata(emp_client_handle emp_handle,
                                  const device_metadata_value_t* value);


  /**
   * This functions tells the EMP client to prepare for shutdown. Should be followed by
   * empcomm_close()
   *
   * @see shutdown_type_t
   * @returns 0 on Ok and -1 on communication error
   *
   */
  int empcomm_shutdown(emp_client_handle emp_handle, shutdown_type_t type);


  /**
   * Set Measurement data for the current Session.
   *
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_set_measurement(emp_client_handle emp_handle,
                              const measurement_event_t* value);

  /**
   * Set Session Metadata
   *
   * @param emp_handle the EMP Client handle
   * @param value the value of the metadata
   *
   * @see session_metadata_t and session_metadata_value_t
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_set_session_metadata(emp_client_handle emp_handle,
                                   const session_metadata_value_t* value);

  /**
   * Set Available / Unavailable
   *
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_set_available(emp_client_handle emp_handle, bool available);


  /**
   * Set View States.
   *
   * @param emp_handle The session handle
   * @param state
   *
   * @see view_state_id_t
   * @return Returns 0 on Ok and -1 on communication error
   */
  int empcomm_view_state_changed(emp_client_handle emp_handle, view_state_id_t state);
  int empcomm_view_state_extended(emp_client_handle emp_handle, view_state_id_t state,
                                  const char* status_code, const char* status_message);

  /**
   * DTV Session.
   *
   * @param emp_handle the EMP Client handle.
   * @param service_info Information about TV channel and delivery system.
   * @param initial_view_state Initial View State - In most cases VIEWSTATE_PLAYING.
   *
   * @see view_state_id_t and dtv_identification_t
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_dtv_session_extended(emp_client_handle emp_handle,
                                   const dtv_identification_t* service_info,
                                   view_state_id_t initial_view_state);

  /**
   * @param emp_handle the EMP Client handle.
   * @param service_info Information about TV channel and delivery system.
   * @param initial_view_state Initial View State - In most cases VIEWSTATE_PLAYING.
   * @param initial_timeshift_delay The initial time shift delay in ms.
   *
   * @see view_state_id_t and dtv_identification_t
   * @return Returns 0 on Ok and -1 on communication error
   */
  int empcomm_dtv_timeshift_session(emp_client_handle emp_handle,
				                            const dtv_identification_t* service_info,
				                            view_state_id_t initial_view_state,
				                            uint32_t initial_timeshift_delay);


  /**
   * VoD Session
   *
   * @param emp_handle the EMP Client handle.
   * @param uri Request uri string.
   * @param protocol Protocol
   * @param source_server String identifying the server model/brand/type.
   * @param initial_view_state Initial View State - In most cases VIEWSTATE_PLAYING.
   *
   * @see protocol_id_t and view_state_id_t
   * @return Returns 0 on Ok and -1 on communication error
   */
  int empcomm_vod_session(emp_client_handle emp_handle, const char* uri, protocol_id_t protocol,
			                    const char *source_server, view_state_id_t initial_view_state);


  /**
   * ABR Session
   *
   * @param emp_handle the EMP Client handle.
   * @param uri Request uri string.
   * @param protocol The specific dynamic streaming protocol used.
   * @param initial_view_state Initial View State - VIEWSTATE_INITIAL_BUFFERING.
   * @param asset Asset
   * @param playlist_type Type of DS Session.
   *
   * @see ds_protocol_id_t, ds_playlist_type_t and view_state_id_t
   * \return Returns 0 on Ok and -1 on communication error
   */
  int empcomm_abr_session(emp_client_handle emp_handle, const char* uri,
                          ds_protocol_id_t protocol, const char* asset,
                          ds_playlist_type_t playlist_type,
                          view_state_id_t initial_view_state);

  /**
   * PVR Session.
   *
   * @param emp_handle the EMP Client handle.
   * @param uri Request uri string.
   * @param initial_view_state: Initial View State - In most cases VIEWSTATE_PLAYING.
   *
   * @see view_state_id_t
   * @return Returns 0 on Ok and -1 on communication error
   */
  int empcomm_pvr_session(emp_client_handle emp_handle, const char* uri,
                          view_state_id_t initial_view_state);

  /**
   * Application Session
   *
   * @param emp_handle The EMP Client handle
   * @param app_name Name
   * @param uri Uri that points to the load point of the application.
   * @param initial_view_state Initial View State - In most cases VIEWSTATE_PLAYING.
   *
   * @see view_state_id_t
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_app_session(emp_client_handle emp_handle, const char* app_name,
                          const char* uri, view_state_id_t initial_view_state);

  /**
   * Exit Session
   *
   * @param emp_handle The EMP Client handle
   *
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_exit_session(emp_client_handle emp_handle);

  /**
   * Undefined Active Session
   *
   * @param emp_handle The EMP Client handle
   *
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_undefined_active_state_session(emp_client_handle emp_handle);

  /**
   * Failed State Session
   *
   * @param emp_handle The EMP Client handle
   * @param error_code A brief string to explain what the error is.
   *
   * @returns 0 on Ok and -1 on communication error
   */
  int empcomm_failed_state_session(emp_client_handle emp_handle, const char* error_code);


  /**
   * Custom Events
   *
   * Events defined by the customer/integrator.
   */
  int empcomm_event(emp_client_handle emp_handle,
                    const char* code,
                    const char* value);

  /**
   * Custom Events with json formatted value string
   *
   * Events defined by the customer/integrator.
   */
  int empcomm_event_json(emp_client_handle emp_handle,
                         const char* code,
                         const char* value);

#include "emp_deprecated.h"

#ifdef __cplusplus
}
#endif

#endif
