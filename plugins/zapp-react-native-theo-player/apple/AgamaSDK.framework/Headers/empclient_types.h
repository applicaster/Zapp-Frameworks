/**
 * Copyright; 2004-2017 Agama Technologies AB
 */


#ifndef EMPCLIENT_TYPES_H
#define EMPCLIENT_TYPES_H

#include <unistd.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

  /**
   * \file empclient_types.h
   *
   * This header file specifies the signature and semantics of the public interface exported
   * by libempclient.
   */

  // All supported measurement types
  typedef enum {
     _MEASUREMENT_MIN = 0,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_AUDIO_BUFFER_OVERFLOW = _MEASUREMENT_MIN,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_AUDIO_BUFFER_UNDERFLOW,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_AUDIO_DECODING_ERROR,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_AUDIO_DISCONTINUITY,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_AUDIO_OUT_OF_SYNC_ERROR,

      /**
       * Collection method: SI. Real valued.
       */
      MEASUREMENT_CPU_USAGE,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_CURRENT_NUMBER_OF_RECORDINGS,

      /**
       *
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_FAN_RPM,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_FEC_CORRECTED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_FEC_UNCORRECTED_PACKET_COUNT,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_FREE_DISK_SPACE,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_FREE_MEMORY,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_HD_TEMPERATURE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_HDCP_AUTHENTICATIONS_FAILED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_HDCP_AUTHENTICATIONS_SUCCEDED,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_IP_INTERFACE_BITRATE,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_IP_STREAM_BITRATE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_NON_AV_DISCONTINUITY,

      /**
       * Collection method: SI, Real valued.
       *
       * @deprecated Use specific MEASUREMENT_RF_BER_* metrics instead.
       */
      MEASUREMENT_RF_BER,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_BER_PREVITERBI,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_BER_POSTVITERBI,

      /**
       * Collection method: SI. Real valued.
       */
      MEASUREMENT_RF_MER,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_SIGNAL_STRENGTH,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_SIGNAL_STRENGTH_DBM_50_OHM,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_SIGNAL_STRENGTH_DBM_75_OHM,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_RF_SIGNAL_STRENGTH_DBMV,

      /**
       * Collection method: SI. Real valued.
       */
      MEASUREMENT_RF_SNR,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RF_UNCORRECTED_BLOCK_ERRORS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_RTP_DROPPED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RTP_LATE_PACKET_DROPPED_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RTP_DUPLICATED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RTP_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_RTP_LOST_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RTP_REORDERED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_SOURCE_BUFFER_OVERFLOW,

      /**
      * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
      */
      MEASUREMENT_SOURCE_BUFFER_UNDERFLOW,

      /**
       * Timeshift delay in milliseconds.
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_TIMESHIFT_DELAY,

      /**
       * Collection method: GAUGE_MIN. Integer valued.
       */
      MEASUREMENT_TR135_GMIN,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_LOSS_EVENTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_LOSS_EVENTS_BEFORE_EC,

      /**
       * Collection method: GAUGE_MAX. Integer valued.
       */
      MEASUREMENT_TR135_MAXIMUM_LOSS_PERIOD,

      /**
       * Collection method: GAUGE_MIN. Integer valued.
       */
      MEASUREMENT_TR135_MINIMUM_LOSS_DISTANCE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_OVERRUNS,

      /**
       * Collection method: CC, Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_SEVERE_LOSS_INDEX_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_UNDERRUNS,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_TS_STREAM_BITRATE,

      /**
       * Collection method: DER. Integer valued.
       */
      MEASUREMENT_UI_REACTIVITY_TIME,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_VIDEO_BUFFER_OVERFLOW,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_VIDEO_BUFFER_UNDERFLOW,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_VIDEO_DECODING_ERROR,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_VIDEO_DISCONTINUITY,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_VIDEO_OUT_OF_SYNC_ERROR,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_CHANNEL_CHANGE_REQUESTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_POST_REPAIR_LOSSES_RCC,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_PRIMARY_RTCP_INPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_PRIMARY_RTCP_OUTPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */

      MEASUREMENT_VQE_RCC_ABORTS_BURST_ACTIVITY,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_BURST_START,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_OTHER,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_RESPONSE_INVALID,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_RESPONSE_TIMEOUT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_SERVER_REJECT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_STUN_TIMEOUT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_ABORTS_TOTAL,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_REQUESTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTCP_INPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTCP_STUN_INPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTCP_STUN_OUTPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_PACKET_DROPS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_PACKET_DROPS_LATE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_PACKETS_RECEIVED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTP_STUN_INPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTP_STUN_OUTPUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_REQUESTS_POLICED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_REQUESTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_TUNER_QUEUE_DROPS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_UNDERRUNS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_RX_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_RX_BYTE_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_RX_CRC_ERROR_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_RX_LOST_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_TX_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_TX_BYTE_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WAN_TX_LOST_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_RX_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_RX_BYTE_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_RX_CRC_ERROR_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_TX_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_TX_BYTE_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_TX_SUCCESSFUL_PACKETS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_WLAN_TX_PACKET_RETRY_COUNTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       *
       * @deprecated Use MEASUREMENT_DS_SEGMENT_PROFILE_BITRATE instead.
       */
      MEASUREMENT_DS_NR_OF_CONTENT_PROFILE_BITRATE_DOWN_CHANGES,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       *
       * @deprecated Use MEASUREMENT_DS_SEGMENT_PROFILE_BITRATE instead.
       */
      MEASUREMENT_DS_NR_OF_CONTENT_PROFILE_BITRATE_UP_CHANGES,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_DS_NR_OF_SEGMENTS_REQUESTED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_DS_NR_OF_SEGMENTS_RECEIVED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       *
       * @deprecated Use MEASUREMENT_DS_NR_OF_REQUEST_ERRORS instead.
       */
      MEASUREMENT_DS_NR_OF_SEGMENT_TIMEOUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       *
       * @deprecated Use MEASUREMENT_DS_NR_OF_REQUEST_ERRORS instead.
       */
      MEASUREMENT_DS_NR_OF_SEGMENT_FAILURES,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       *
       * @deprecated Use MEASUREMENT_DS_NR_OF_REQUEST_ERRORS instead.
       */
      MEASUREMENT_DS_NR_OF_SEGMENT_UNDERRUNS,

      /**
       * Collection method: DER. Integer valued.
       */
      MEASUREMENT_DS_SEGMENT_READ_BITRATE,

      /**
       * Collection method: DER. Integer valued.
       */
      MEASUREMENT_DS_SEGMENT_PROFILE_BITRATE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_DS_SEGMENT_NR_READ_BITRATE_BELOW_PROFILE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       * @deprecated
       */
      MEASUREMENT_DS_SEGMENTS_TOTAL_TIME,

      /**
       * Collection method: SI. Integer valued.
       */
      MEASUREMENT_DS_NR_OF_SEGMENT_BUFFER_LEVEL,


      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_CORRECTED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_PACKETS_REQUESTED,

      /**
       * Collection method: GAUGE_MAX. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RET_MAX_HOLE_SIZE,

      /**
       * Collection method: DER. Integer valued.
       */
      MEASUREMENT_APPLICATION_STARTUP_TIME,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_BYTES_RECEIVED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_NR_OF_FRAMES_ENCODED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_NR_OF_FRAMES_DROPPED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes
       */
      MEASUREMENT_NUMBER_OF_FRAMES_REPEATED,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_WLAN_SIGNAL_STRENGTH,

      /**
       * Collection method: SI, Real valued.
       *
       * @deprecated Use MEASUREMENT_WLAN_SIGNAL_STRENGTH_DBM instead.
       */
      MEASUREMENT_WLAN_SIGNAL_STRENGTH_DBMV,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_WLAN_SIGNAL_STRENGTH_DBM,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_WLAN_PER,

      /**
       * Collection method: SI. Real valued.
       */
      MEASUREMENT_WLAN_SNR,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_MOBILE_SIGNAL_STRENGTH,

      /**
       * Collection method: SI, Real valued.
       *
       * @deprecated Use MEASUREMENT_MOBILE_SIGNAL_STRENGTH_DBM instead.
       */
      MEASUREMENT_MOBILE_SIGNAL_STRENGTH_DBMV,

      /**
       * Collection method: SI, Real valued.
       */
      MEASUREMENT_MOBILE_SIGNAL_STRENGTH_DBM,

      /**
       * Collection method: SI. Real valued.
       */
      MEASUREMENT_MOBILE_SNR,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_DS_NR_OF_REQUESTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_DS_NR_OF_REQUEST_ERRORS,

      /**
       * Collection method: DER. Integer valued.
       */
      MEASUREMENT_DS_SEGMENT_PROFILE_NR,

      /**
       * Collection method: DER. Text valued.
       */
      MEASUREMENT_DS_SEGMENT_SOURCE_IP,

      /**
       * Collection method: DER. Text valued.
       */
      MEASUREMENT_DS_MANIFEST_SOURCE_IP,

      /**
       * NOTE: Internal measurement! Any attempt to set this metric will be ignored.
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_INTERNAL_NEGATIVE_CC_INCREMENTS,

      /**
       * NOTE: Internal measurement! Any attempt to set this metric will be ignored.
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_INTERNAL_NEGATIVE_CC_INCREMENTS_IN_HOLDOFF,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_CA_GENERIC_ERRORS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_EPG_NUMBER_OF_REQUESTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_EPG_NUMBER_OF_TIMEOUTS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_POST_REPAIR_OUTPUTS,
     
      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_PRE_REPAIR_LOSSES,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_POST_REPAIR_LOSSES,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_RCC_WITH_LOSS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_RTP_EXPECTED_PACKET_COUNT,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_PACKETS_EXPECTED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_PACKETS_RECEIVED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_PACKETS_LOST,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_TR135_PACKETS_LOST_BEFORE_EC,

      MEASUREMENT_HTTP_REQUEST_STATUS_CODE_1XX,

      MEASUREMENT_HTTP_REQUEST_STATUS_CODE_2XX,

      MEASUREMENT_HTTP_REQUEST_STATUS_CODE_3XX,

      MEASUREMENT_HTTP_REQUEST_STATUS_CODE_4XX,

      MEASUREMENT_HTTP_REQUEST_STATUS_CODE_5XX,

      MEASUREMENT_NR_OF_FRAMES_DECODED,

      /** Collection method: SI. Real valued. Affects errored millisecond metrics: No */
      MEASUREMENT_CPU_TEMPERATURE,


      /** Collection method: SI. Integer valued. Milliseconds. Affects errored millisecond metrics: No */
      MEASUREMENT_PLAYBACK_DELTA_TO_ORIGIN,
      /** Collection method: Last. Integer valued. Milliseconds. Affects errored millisecond metrics: No */
      MEASUREMENT_ORIGIN_TIMESTAMP,

      /** Collection method: SI, Real valued. */
      MEASUREMENT_RF_BER_PREREEDSOLOMON,
      /** Collection method: SI, Real valued. */
      MEASUREMENT_RF_BER_PREBCH,
      /** Collection method: SI, Real valued. */
      MEASUREMENT_RF_BER_POSTBCH,
      /** Collection method: SI, Real valued. */
      MEASUREMENT_RF_BER_PRELDPC,
      /** Collection method: SI, Real valued. */
      MEASUREMENT_RF_BER_POSTLDPC,

      /** Collection method: Last. Integer valued. Milliseconds. Affects errored millisecond metrics: No */
      MEASUREMENT_PLAYBACK_POSITION,

      /** Collection method: SI, Integer valued. Milliseconds. Affects errored millisecond metrics: No */
      MEASUREMENT_BUFFER_LENGTH,

      /** Collection method: SI, Integer valued. Milliseconds. Affects errored millisecond metrics: No */
      MEASUREMENT_STREAM_DELTA_TO_ORIGIN,

      /** Alias measurements **/

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTP_DROPS=MEASUREMENT_RET_PACKET_DROPS,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTP_DROPS_LATE=MEASUREMENT_RET_PACKET_DROPS_LATE,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIR_RTP_INPUTS=MEASUREMENT_RET_PACKETS_RECEIVED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIRS_POLICED=MEASUREMENT_RET_REQUESTS_POLICED,

      /**
       * Collection method: CC. Integer valued. Affects errored millisecond metrics: No
       */
      MEASUREMENT_VQE_REPAIRS_REQUESTED=MEASUREMENT_RET_REQUESTS,

      MEASUREMENT_NR_OF_FRAMES_REPEATED=MEASUREMENT_NUMBER_OF_FRAMES_REPEATED,

      MEASUREMENT_RET_PRE_REPAIR_LOSSES=MEASUREMENT_VQE_PRE_REPAIR_LOSSES,

      MEASUREMENT_RET_POST_REPAIR_LOSSES=MEASUREMENT_VQE_POST_REPAIR_LOSSES,

      /** Collection method: Last. Integer valued. Affects errored millisecond metrics: No */
      MEASUREMENT_FCC_REQUESTS=MEASUREMENT_VQE_RCC_REQUESTS,
      /** Collection method: Last. Integer valued. Affects errored millisecond metrics: No */
      MEASUREMENT_FCC_ABORTS=MEASUREMENT_VQE_RCC_ABORTS_TOTAL,
      /** Collection method: Last. Integer valued. Affects errored millisecond metrics: No */
      MEASUREMENT_FCC_PACKET_LOSS=MEASUREMENT_VQE_POST_REPAIR_LOSSES_RCC,
      /** Collection method: CC. Integer valued. Affects errored millisecond metrics: Yes */
      MEASUREMENT_NUMBER_OF_FRAMES_DROPPED=MEASUREMENT_NR_OF_FRAMES_DROPPED,

      MEASUREMENT_NUMBER_OF_FRAMES_DECODED=MEASUREMENT_NR_OF_FRAMES_DECODED,

      MEASUREMENT_SEGMENT_READ_BITRATE=MEASUREMENT_DS_SEGMENT_READ_BITRATE,

      MEASUREMENT_SEGMENT_PROFILE_NUMBER=MEASUREMENT_DS_SEGMENT_PROFILE_NR,

      MEASUREMENT_SEGMENT_PROFILE_BITRATE=MEASUREMENT_DS_SEGMENT_PROFILE_BITRATE,

      _MEASUREMENT_MAX = MEASUREMENT_STREAM_DELTA_TO_ORIGIN
  } measurement_t;

  const int NR_OF_MEASUREMENTS = (_MEASUREMENT_MAX - _MEASUREMENT_MIN) + 1;


  /**
  * The type used for registering measurement values via empcomm_set_measurement().
  * Percentage values should be double values in the range [0.0, 1.0].
  */
  typedef struct {
    measurement_t type;
    union {
      int64_t int64_value;
      double double_value;
      const char* text_value;
    };
  } measurement_event_t;


  /**
   * macros to keep pre 3.7.0.0 "PROBE_METADATA" naming for backwards
   * compatibility
   */
#define PROBE_METADATA_STB_MAC                                DEVICE_METADATA_STB_MAC
#define PROBE_METADATA_STB_IP                                 DEVICE_METADATA_STB_IP
#define PROBE_METADATA_STB_SERIAL_NUMBER                      DEVICE_METADATA_STB_SERIAL_NUMBER
#define PROBE_METADATA_STB_MANUFACTURER                       DEVICE_METADATA_STB_MANUFACTURER
#define PROBE_METADATA_STB_MODEL                              DEVICE_METADATA_STB_MODEL
#define PROBE_METADATA_STB_CHIPSET                            DEVICE_METADATA_STB_CHIPSET
#define PROBE_METADATA_EMPCLIENT_INTEGRATION_VERSION          DEVICE_METADATA_EMPCLIENT_INTEGRATION_VERSION
#define PROBE_METADATA_EMPCLIENT_INTEGRATION_BUILDDATE        DEVICE_METADATA_EMPCLIENT_INTEGRATION_BUILDDATE
#define PROBE_METADATA_INTEGRATION_SPECIFIC_PROBE_METADATA    DEVICE_METADATA_INTEGRATION_SPECIFIC_DEVICE_METADATA
#define PROBE_METADATA_PLATFORM_VERSION                       DEVICE_METADATA_PLATFORM_VERSION
#define PROBE_METADATA_FIRMWARE_VERSION                       DEVICE_METADATA_FIRMWARE_VERSION
#define PROBE_METADATA_MIDDLEWARE                             DEVICE_METADATA_MIDDLEWARE
#define PROBE_METADATA_MIDDLEWARE_VERSION                     DEVICE_METADATA_MIDDLEWARE_VERSION
#define PROBE_METADATA_CA_SYSTEM                              DEVICE_METADATA_CA_SYSTEM
#define PROBE_METADATA_EDID_INFORMATION                       DEVICE_METADATA_EDID_INFORMATION
#define PROBE_METADATA_CONFIGURATION_SET_FROM                 DEVICE_METADATA_CONFIGURATION_SET_FROM
#define PROBE_METADATA_DISK_SIZE                              DEVICE_METADATA_DISK_SIZE
#define PROBE_METADATA_WAN_LINK_SPEED                         DEVICE_METADATA_WAN_LINK_SPEED
#define PROBE_METADATA_WLAN_CHANNEL                           DEVICE_METADATA_WLAN_CHANNEL
#define PROBE_METADATA_WLAN_BANDWIDTH                         DEVICE_METADATA_WLAN_BANDWIDTH
#define PROBE_METADATA_WLAN_CHANNEL_BANDWIDTH                 DEVICE_METADATA_WLAN_CHANNEL_BANDWIDTH
#define PROBE_METADATA_STB_EXTERNAL_ID                        DEVICE_METADATA_STB_EXTERNAL_ID
#define PROBE_METADATA_LOCATION_DESCRIPTION                   DEVICE_METADATA_LOCATION_DESCRIPTION
#define PROBE_METADATA_SMARTCARD_ID                           DEVICE_METADATA_SMARTCARD_ID
#define PROBE_METADATA_CA_PAIRING_ID                          DEVICE_METADATA_CA_PAIRING_ID
#define PROBE_METADATA_CA_ENTITLEMENT                         DEVICE_METADATA_CA_ENTITLEMENT
#define PROBE_METADATA_PARENTAL_CONTROL_PARAMETERS            DEVICE_METADATA_PARENTAL_CONTROL_PARAMETERS
#define PROBE_METADATA_USER_PIN_CODE                          DEVICE_METADATA_USER_PIN_CODE
#define PROBE_METADATA_SERVICE_GROUP                          DEVICE_METADATA_SERVICE_GROUP
#define PROBE_METADATA_USER_ACCOUNT_ID                        DEVICE_METADATA_USER_ACCOUNT_ID
#define PROBE_METADATA_DEVICE_TYPE                            DEVICE_METADATA_DEVICE_TYPE
#define PROBE_METADATA_SOFT_STANDBY                           DEVICE_METADATA_SOFT_STANDBY
#define PROBE_METADATA_DEVICE_ID                              DEVICE_METADATA_DEVICE_ID
#define PROBE_METADATA_SERVICE_STATUS                         DEVICE_METADATA_SERVICE_STATUS
#define PROBE_METADATA_EMM                                    DEVICE_METADATA_EMM
#define PROBE_METADATA_RF                                     DEVICE_METADATA_RF
#define PROBE_METADATA_NETWORK                                DEVICE_METADATA_NETWORK
#define PROBE_METADATA_MULTISCREEN                            DEVICE_METADATA_MULTISCREEN

  /**
   * Optional probe medatata parameters.
   */
  typedef enum {
    _DEVICE_METADATA_MIN = 0,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_MAC = _DEVICE_METADATA_MIN,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_IP,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_SERIAL_NUMBER,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_MANUFACTURER,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_MODEL,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_CHIPSET,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_EMPCLIENT_INTEGRATION_VERSION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_EMPCLIENT_INTEGRATION_BUILDDATE,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_INTEGRATION_SPECIFIC_DEVICE_METADATA,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_PLATFORM_VERSION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_FIRMWARE_VERSION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_MIDDLEWARE,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_MIDDLEWARE_VERSION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_CA_SYSTEM,

    /**
     * Value type: @c binary
     */
    DEVICE_METADATA_EDID_INFORMATION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_CONFIGURATION_SET_FROM,

    /**
     * Value type: @c uint32
     */
    DEVICE_METADATA_DISK_SIZE,

    /**
     * Value type: @c uint32
     * @deprecated
     */
    DEVICE_METADATA_WAN_LINK_SPEED,

    /**
     * Value type: @c uint32
     * @deprecated
     */
    DEVICE_METADATA_WLAN_CHANNEL,

    /**
     * Value type: @c uint32
     * @deprecated
     */
    DEVICE_METADATA_WLAN_BANDWIDTH,

    /**
     * Value type: @c uint32
     * @deprecated
     */
    DEVICE_METADATA_WLAN_CHANNEL_BANDWIDTH,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_STB_EXTERNAL_ID,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_LOCATION_DESCRIPTION,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_SMARTCARD_ID,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_CA_PAIRING_ID,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_CA_ENTITLEMENT,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_PARENTAL_CONTROL_PARAMETERS,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_USER_PIN_CODE,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_SERVICE_GROUP,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_USER_ACCOUNT_ID,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_DEVICE_TYPE,

    /**
     * Value type: @c uint8
     */
    DEVICE_METADATA_SOFT_STANDBY,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_DEVICE_ID,

    /**
     * Value type: @c text
     */
    DEVICE_METADATA_SERVICE_STATUS,

    /**
     * Value type: @c binary
     */
    DEVICE_METADATA_EMM,

    /**
     * Value type: @c binary
     */
    DEVICE_METADATA_RF,

    /**
     * Value type: @c binary
     */
    DEVICE_METADATA_NETWORK,

    /**
     * Value type: @c binary
     */
    DEVICE_METADATA_MULTISCREEN,

    /** Value type: @c binary (kvs structure) */
    DEVICE_METADATA_HDD_PARAMETERS,

    DEVICE_METADATA_DEVICE_OS,

    DEVICE_METADATA_DEVICE_BROWSER,

    DEVICE_METADATA_APPLICATION,

    DEVICE_METADATA_APPLICATION_VERSION,

    DEVICE_METADATA_DEVICE_LATITUDE,

    DEVICE_METADATA_DEVICE_LONGITUDE,

    DEVICE_METADATA_DATA_CONNECTION_TYPE,

    /** Alias probe metadata **/

    DEVICE_METADATA_DEVICE_MANUFACTURER = DEVICE_METADATA_STB_MANUFACTURER,
    DEVICE_METADATA_DEVICE_MODEL = DEVICE_METADATA_STB_MODEL,
    DEVICE_METADATA_DEVICE_IP = DEVICE_METADATA_STB_IP,
    DEVICE_METADATA_DEVICE_OS_VERSION = DEVICE_METADATA_PLATFORM_VERSION,
    DEVICE_METADATA_PLAYER = DEVICE_METADATA_MIDDLEWARE,
    DEVICE_METADATA_PLAYER_VERSION = DEVICE_METADATA_MIDDLEWARE_VERSION,
    DEVICE_METADATA_DEVICE_BROWSER_VERSION = DEVICE_METADATA_FIRMWARE_VERSION,


    _DEVICE_METADATA_MAX = DEVICE_METADATA_DATA_CONNECTION_TYPE
  } device_metadata_t;
  const int NR_OF_DEVICE_METADATA_TYPES = (_DEVICE_METADATA_MAX - _DEVICE_METADATA_MIN) + 1;

  typedef enum {
    VALUE_UINT8 = 1,
    VALUE_UINT16,
    VALUE_UINT32,
    VALUE_UINT64,
    VALUE_DOUBLE,
    VALUE_TEXT,
    VALUE_BINARY
  } probe_metadata_data_value_t;

  const probe_metadata_data_value_t probe_metadata_value_types[NR_OF_DEVICE_METADATA_TYPES] = {
    VALUE_TEXT,   /* DEVICE_METADATA_STB_MAC                             */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_IP                              */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_SERIAL_NUMBER                   */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_MANUFACTURER                    */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_MODEL                           */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_CHIPSET                         */
    VALUE_TEXT,   /* DEVICE_METADATA_EMPCLIENT_INTEGRATION_VERSION       */
    VALUE_TEXT,   /* DEVICE_METADATA_EMPCLIENT_INTEGRATION_BUILDDATE     */
    VALUE_TEXT,   /* DEVICE_METADATA_INTEGRATION_SPECIFIC_DEVICE_METADATA */
    VALUE_TEXT,   /* DEVICE_METADATA_PLATFORM_VERSION                    */
    VALUE_TEXT,   /* DEVICE_METADATA_FIRMWARE_VERSION                    */
    VALUE_TEXT,   /* DEVICE_METADATA_MIDDLEWARE                          */
    VALUE_TEXT,   /* DEVICE_METADATA_MIDDLEWARE_VERSION                  */
    VALUE_TEXT,   /* DEVICE_METADATA_CA_SYSTEM                           */
    VALUE_BINARY, /* DEVICE_METADATA_EDID_INFORMATION                    */
    VALUE_TEXT,   /* DEVICE_METADATA_CONFIGURATION_SET_FROM              */
    VALUE_UINT32, /* DEVICE_METADATA_DISK_SIZE                           */
    VALUE_UINT32, /* DEVICE_METADATA_WAN_LINK_SPEED                      */
    VALUE_UINT32, /* DEVICE_METADATA_WLAN_CHANNEL                        */
    VALUE_UINT32, /* DEVICE_METADATA_WLAN_BANDWIDTH                      */
    VALUE_UINT32, /* DEVICE_METADATA_WLAN_CHANNEL_BANDWIDTH              */
    VALUE_TEXT,   /* DEVICE_METADATA_STB_EXTERNAL_ID                     */
    VALUE_TEXT,   /* DEVICE_METADATA_LOCATION_DESCRIPTION                */
    VALUE_TEXT,   /* DEVICE_METADATA_SMARTCARD_ID                        */
    VALUE_TEXT,   /* DEVICE_METADATA_CA_PAIRING_ID                       */
    VALUE_TEXT,   /* DEVICE_METADATA_CA_ENTITLEMENT                      */
    VALUE_TEXT,   /* DEVICE_METADATA_PARENTAL_CONTROL_PARAMETERS         */
    VALUE_TEXT,   /* DEVICE_METADATA_USER_PIN_CODE                       */
    VALUE_TEXT,   /* DEVICE_METADATA_SERVICE_GROUP                       */
    VALUE_TEXT,   /* DEVICE_METADATA_USER_ACCOUNT_ID                     */
    VALUE_TEXT,   /* DEVICE_METADATA_DEVICE_TYPE                         */
    VALUE_UINT8,  /* DEVICE_METADATA_SOFT_STANDBY                        */
    VALUE_TEXT,   /* DEVICE_METADATA_DEVICE_ID                           */
    VALUE_TEXT,   /* DEVICE_METADATA_SERVICE_STATUS                      */
    VALUE_BINARY, /* DEVICE_METADATA_EMM                                 */
    VALUE_BINARY, /* DEVICE_METADATA_RF                                  */
    VALUE_BINARY, /* DEVICE_METADATA_NETWORK                             */
    VALUE_BINARY, /* DEVICE_METADATA_MULTISCREEN                         */
    VALUE_BINARY, /* DEVICE_METADATA_HDD_PARAMETERS                      */
    VALUE_TEXT,   /* DEVICE_METADATA_OS                                  */
    VALUE_TEXT,   /* DEVICE_METADATA_BROWSER                             */
    VALUE_TEXT,   /* DEVICE_METADATA_APPLICATION                         */
    VALUE_TEXT,   /* DEVICE_METADATA_APPLICATION_VERSION                 */
    VALUE_DOUBLE, /* DEVICE_METADATA_DEVICE_LATITUDE                     */
    VALUE_DOUBLE, /* DEVICE_METADATA_DEVICE_LONGITUDE                    */
    VALUE_TEXT    /* DEVICE_METADATA_DATA_CONNECTION_TYPE                */
  };

  /**
  * The type used for registering device metadata values via empcomm_set_device_metadata().
  */
  typedef struct {
    device_metadata_t type;
    union {
      uint8_t     uint8_value;
      uint16_t    uint16_value;
      uint32_t    uint32_value;
      uint64_t    uint64_value;
      double      double_value;
      const char* text_value;
      struct {
        const uint8_t* value;
        uint16_t       length;
      } binary;
    };
  } device_metadata_value_t;

  typedef device_metadata_t probe_metadata_t;
  typedef device_metadata_value_t probe_metadata_value_t;

  /**
   * Available DTV delivery system types
   */
  typedef enum {
      DVB_C,
      DVB_S,
      DVB_T,
      IP,
      ATSC,
      ISDB_T,
  } dtv_delivery_system_t;


  const unsigned int MAX_IP_STRING_LENGTH = 45;

  /**
  * Struct for TV channel information to use with
  * empcomm_dtv_session_extended() and empcomm_dtv_timeshift_session().
  */
  typedef struct {
      dtv_delivery_system_t dtv_delivery_system;

      union {
          struct {
              /** Expects IP on decimal form: XXX.XXX.XXX.XXX. */
              char ip[MAX_IP_STRING_LENGTH + 1];
              uint16_t port;
          } multicast;

          struct {
              uint16_t onid;
              uint16_t tsid;
              uint16_t sid;
          } rf;
      };
  } dtv_identification_t;


  /**
   * macros to keep pre 3.7.0.0 "STATE_METADATA" naming for backwards
   * compatibility
   */
#define STATE_METADATA_DE_JITTER_BUFFER_SIZE_IN_KILOBYTE  SESSION_METADATA_DE_JITTER_BUFFER_SIZE_IN_KILOBYTE
#define STATE_METADATA_CHANNEL_CHANGE_TIME                SESSION_METADATA_CHANNEL_CHANGE_TIME
#define STATE_METADATA_IGMP_JOIN_TIME                     SESSION_METADATA_IGMP_JOIN_TIME
#define STATE_METADATA_IGMP_LEAVE_TIME                    SESSION_METADATA_IGMP_LEAVE_TIME
#define STATE_METADATA_INITIAL_BUFFERING_TIME             SESSION_METADATA_INITIAL_BUFFERING_TIME
#define STATE_METADATA_INITIAL_RANDOM_ACCESS_TIME         SESSION_METADATA_INITIAL_RANDOM_ACCESS_TIME
#define STATE_METADATA_RTSP_SETUP_TIME                    SESSION_METADATA_RTSP_SETUP_TIME
#define STATE_METADATA_RTSP_TEARDOWN_TIME                 SESSION_METADATA_RTSP_TEARDOWN_TIME
#define STATE_METADATA_TR135_SEVERE_LOSS_MIN_DISTANCE     SESSION_METADATA_TR135_SEVERE_LOSS_MIN_DISTANCE
#define STATE_METADATA_TUNED_FREQUENCY                    SESSION_METADATA_TUNED_FREQUENCY
#define STATE_METADATA_TUNING_TIME                        SESSION_METADATA_TUNING_TIME
#define STATE_METADATA_VOD_SETUP_DELAY                    SESSION_METADATA_VOD_SETUP_DELAY
#define STATE_METADATA_GENERIC_DESCRIPTION                SESSION_METADATA_GENERIC_DESCRIPTION
#define STATE_METADATA_CONTENT_TITLE                      SESSION_METADATA_CONTENT_TITLE
#define STATE_METADATA_CONTENT_DESCRIPTION                SESSION_METADATA_CONTENT_DESCRIPTION
#define STATE_METADATA_SPECIFIED_DURATION                 SESSION_METADATA_SPECIFIED_DURATION
#define STATE_METADATA_DS_NR_OF_SEGMENT_BUFFERS           SESSION_METADATA_DS_NR_OF_SEGMENT_BUFFERS
#define STATE_METADATA_DS_SEGMENT_BUFFER_SIZE             SESSION_METADATA_DS_SEGMENT_BUFFER_SIZE
#define STATE_METADATA_DS_NR_OF_PREBUFFERED_SEGMENTS      SESSION_METADATA_DS_NR_OF_PREBUFFERED_SEGMENTS
#define STATE_METADATA_DS_SEGMENT_PREBUFFER_SIZE          SESSION_METADATA_DS_SEGMENT_PREBUFFER_SIZE
#define STATE_METADATA_NR_OF_REDIRECTS                    SESSION_METADATA_NR_OF_REDIRECTS
#define STATE_METADATA_DS_ORIGINATING_SOURCE              SESSION_METADATA_DS_ORIGINATING_SOURCE
#define STATE_METADATA_DS_ORIGINATING_SERVER_MANIFEST     SESSION_METADATA_DS_ORIGINATING_SERVER_MANIFEST
#define STATE_METADATA_DS_ORIGINATING_SERVER_SEGMENT      SESSION_METADATA_DS_ORIGINATING_SERVER_SEGMENT
#define STATE_METADATA_DS_INITIAL_PROFILE                 SESSION_METADATA_DS_INITIAL_PROFILE
#define STATE_METADATA_DS_NR_OF_CONTENT_PROFILES          SESSION_METADATA_DS_NR_OF_CONTENT_PROFILES
#define STATE_METADATA_DS_MANIFEST_FILE                   SESSION_METADATA_DS_MANIFEST_FILE
#define STATE_METADATA_HLS_INITIAL_PATPMT                 SESSION_METADATA_HLS_INITIAL_PATPMT
#define STATE_METADATA_DS_PLAYLIST_TYPE                   SESSION_METADATA_DS_PLAYLIST_TYPE
#define STATE_METADATA_DATA_CONNECTION_TYPE               SESSION_METADATA_DATA_CONNECTION_TYPE
#define STATE_METADATA_IP_NEGOTIATED_BITRATE              SESSION_METADATA_IP_NEGOTIATED_BITRATE
#define STATE_METADATA_CONTENT_CA_SYSTEM                  SESSION_METADATA_CONTENT_CA_SYSTEM
#define STATE_METADATA_RF_MODULATION                      SESSION_METADATA_RF_MODULATION
#define STATE_METADATA_RF_SYMBOLRATE                      SESSION_METADATA_RF_SYMBOLRATE
#define STATE_METADATA_RF_STANDARD                        SESSION_METADATA_RF_STANDARD
#define STATE_METADATA_DS_EXIT_BEFORE_INITIAL_PLAY        SESSION_METADATA_DS_EXIT_BEFORE_INITIAL_PLAY
#define STATE_METADATA_DS_EXIT_WHILE_STALLED              SESSION_METADATA_DS_EXIT_WHILE_STALLED
#define STATE_METADATA_CONTENT_SERVICE_TITLE              SESSION_METADATA_CONTENT_SERVICE_TITLE
#define STATE_METADATA_CONTENT_TYPE                       SESSION_METADATA_CONTENT_TYPE
#define STATE_METADATA_APP_SUCCESSFULLY_STARTED           SESSION_METADATA_APP_SUCCESSFULLY_STARTED
#define STATE_METADATA_APP_STARTUP_TIME                   SESSION_METADATA_APP_STARTUP_TIME
#define STATE_METADATA_STREAM_SETUP_TIME                  SESSION_METADATA_STREAM_SETUP_TIME

  typedef enum {
      _SESSION_METADATA_MIN = 0,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_DE_JITTER_BUFFER_SIZE_IN_KILOBYTE  = _SESSION_METADATA_MIN,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_CHANNEL_CHANGE_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_IGMP_JOIN_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_IGMP_LEAVE_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_INITIAL_BUFFERING_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_INITIAL_RANDOM_ACCESS_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_RTSP_SETUP_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_RTSP_TEARDOWN_TIME,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_TR135_SEVERE_LOSS_MIN_DISTANCE,

      /**
       * Data type: uint64
       */
      SESSION_METADATA_TUNED_FREQUENCY,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_TUNING_TIME,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_VOD_SETUP_DELAY,

      /**
       * Data type: text
       */
      SESSION_METADATA_GENERIC_DESCRIPTION,

      /**
       * Data type: text
       */
      SESSION_METADATA_CONTENT_TITLE,

      /**
       * Data type: text
       */
      SESSION_METADATA_CONTENT_DESCRIPTION,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_SPECIFIED_DURATION,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_DS_NR_OF_SEGMENT_BUFFERS,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_DS_SEGMENT_BUFFER_SIZE,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_DS_NR_OF_PREBUFFERED_SEGMENTS,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_DS_SEGMENT_PREBUFFER_SIZE,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_NR_OF_REDIRECTS,

      /**
       * Data type: text
       */
      SESSION_METADATA_DS_ORIGINATING_SOURCE,

      /**
       * Data type: text
       */
      SESSION_METADATA_DS_ORIGINATING_SERVER_MANIFEST,

      /**
       * Data type: text
       */
      SESSION_METADATA_DS_ORIGINATING_SERVER_SEGMENT,

      /**
       * Data type: text
       */
      SESSION_METADATA_DS_INITIAL_PROFILE,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_DS_NR_OF_CONTENT_PROFILES,

      /**
       * Data type: text
       */
      SESSION_METADATA_DS_MANIFEST_FILE,

      /**
       * Data type: uint16
       */
      SESSION_METADATA_HLS_INITIAL_PATPMT,

      /**
       * Data type: uint16 -- ds_playlist_type_t
       * @deprecated
       */
      SESSION_METADATA_DS_PLAYLIST_TYPE,

      /**
       * Data type: text
       */
      SESSION_METADATA_DATA_CONNECTION_TYPE,

      /**
       * Data type: uint32
       */
      SESSION_METADATA_IP_NEGOTIATED_BITRATE,

      /**
       * Data type: text
       */
      SESSION_METADATA_CONTENT_CA_SYSTEM,

      /**
       * Data type: text
       */
      SESSION_METADATA_RF_MODULATION,

      /**
       * Data type: uint64
       */
      SESSION_METADATA_RF_SYMBOLRATE,

      /**
       * Data type: text
       */
      SESSION_METADATA_RF_STANDARD,

      /**
       * Data type: uint16 (actual: boolean; 0 or 1)
       * @deprecated - Set internally
       */
      SESSION_METADATA_DS_EXIT_BEFORE_INITIAL_PLAY,

      /**
       * Data type: uint16 (actual: boolean; 0 or 1)
       * @deprecated - Set internally
       */
      SESSION_METADATA_DS_EXIT_WHILE_STALLED,

      /**
       * Data type: text
       */
      SESSION_METADATA_CONTENT_SERVICE_TITLE,
      
      /**
       * Data type: text
       */
      SESSION_METADATA_CONTENT_TYPE,

      /**
       * Data type: uint16 (actual: boolean; 0 or 1)
       */
      SESSION_METADATA_APP_SUCCESSFULLY_STARTED,

      /*
       * Data type: uint32
       * Unit: ms
       */
      SESSION_METADATA_APP_STARTUP_TIME,

      /**
       * Data type: text
       */
      SESSION_METADATA_CDN,

      /** Alias State metadata **/

      SESSION_METADATA_STREAM_SETUP_TIME = SESSION_METADATA_RTSP_SETUP_TIME,

      SESSION_METADATA_NUMBER_OF_CONTENT_PROFILES = SESSION_METADATA_DS_NR_OF_CONTENT_PROFILES,

      SESSION_METADATA_ASSET_DURATION = SESSION_METADATA_SPECIFIED_DURATION,

      SESSION_METADATA_MANIFEST_URI = SESSION_METADATA_DS_ORIGINATING_SERVER_MANIFEST,

      SESSION_METADATA_SERVICE_NAME = SESSION_METADATA_CONTENT_SERVICE_TITLE,

      _SESSION_METADATA_MAX = SESSION_METADATA_CDN
  } session_metadata_t;


  /**
  * Struct used to send parameters to empcomm_set_state_metadata().
  */
  typedef struct {
    session_metadata_t type;
    union {
      uint16_t  uint16_value;
      uint32_t  uint32_value;
      uint64_t  uint64_value;
      const char* text_value;
      struct {
        const uint8_t* value;
        uint16_t       length;
      } binary;
    };
  } session_metadata_value_t;

  typedef session_metadata_t state_metadata_t;
  typedef session_metadata_value_t state_metadata_value_t;

  /**
   * Available View States
   */
  typedef enum {
    UNDEFINED_VIEWSTATE=0,
    VIEWSTATE_PAUSED = 1,
    VIEWSTATE_PLAYING = 2,
    VIEWSTATE_FASTFORWARDING = 3,
    VIEWSTATE_REWINDING = 4,
    VIEWSTATE_FAILED = 5,
    VIEWSTATE_INITIAL_BUFFERING = 6,
    VIEWSTATE_STALLED = 7,
    VIEWSTATE_NO_ACCESS = 8,
    VIEWSTATE_SEEK = 9,
  } view_state_id_t;


  /**
   * Available VOD protocols
   */
  typedef enum {
    UNDEFINED_PROTOCOL=0,
    PROTOCOL_HTTP = 1,
    PROTOCOL_RTSP = 2,
    PROTOCOL_MYRIO = 3
  } protocol_id_t;


  /**
   * Available dynamic streaming protocols
   */
  typedef enum {
    DS_PROTOCOL_UNDEFINED=0,
    DS_PROTOCOL_APPLE_HLS = 1,
    DS_PROTOCOL_MS_SMOOTH = 2,
    DS_PROTOCOL_ADOBE_HDS = 3,
    DS_PROTOCOL_MPEG_DASH = 4,
  } ds_protocol_id_t;

  /**
   * The type of a dynamic streaming session.
   */
  typedef enum {
    DS_PLAYLIST_TYPE_EVENT=1,
    DS_PLAYLIST_TYPE_VOD=2,
    DS_PLAYLIST_TYPE_LIVE=3,
  } ds_playlist_type_t;




  /**
   * Return type from stb_info_set_external_config(), if prefixed by deprecated_
   * the return code is no longer in use. Just to be sure that no conflict should occur
   * if empclient-server is rebuilt but the client code is not.
  */
  typedef enum {
    success,
    option_too_big,
    syntactic_error,
    unknown_option,
    invalid_operator_id,
    invalid_error_holdoff_time,
    invalid_force_basic_vod,
    deprecated_invalid_err_ms_res,
    invalid_err_ms_mask,
    invalid_zap_time,
    invalid_idle_time_limit,
    invalid_report_interval,
    invalid_report_delay_time,
    invalid_use_redirect_uri,
    invalid_encryption_key_file,
    invalid_use_encryption,
    invalid_protocol,
    invalid_after_initial_buffering_allow,
    invalid_after_seek_allow,
    invalid_stalled_after_initial_buffering_time,
    invalid_stalled_after_seek_time,
  } config_result_t;


  /**
   * The type of shutdown.
   */
  typedef enum {
    shutdown_normal_shutdown      = 0x01,
    shutdown_reboot               = 0x02,
    shutdown_hard_standby         = 0x03,
    /**
     * Using shutdown_soft_standby is deprecated and is
     * handled in the same way as shutdown_hard_standby.
     *
     * Use DEVICE_METADATA_SOFT_STANDBY instead.
     */
    shutdown_soft_standby         = 0x03,
    
    shutdown_restart              = 0x04,
    shutdown_abnormal_termination = 0x05
  } shutdown_type_t;


  /**
   * Deprecated
   */
  typedef enum {
    DISTORTION_MIN = 0,
    NON_AV_DISCONTINUITY=1,
    SOURCE_BUFFER_OVERFLOW=2,
    SOURCE_BUFFER_UNDERFLOW=3,
    VIDEO_BUFFER_OVERFLOW=4,
    VIDEO_BUFFER_UNDERFLOW=5,
    AUDIO_BUFFER_OVERFLOW=6,
    AUDIO_BUFFER_UNDERFLOW=7,
    VIDEO_DECODING_ERROR=8,
    AUDIO_DECODING_ERROR=9,
    VIDEO_OUT_OF_SYNC_ERROR=10,
    AUDIO_OUT_OF_SYNC_ERROR=11,
    VIDEO_DISCONTINUITY=12,
    AUDIO_DISCONTINUITY=13,
    RTP_PACKET_LOSS_CNT=14,
    FEC_PACKET_CORRECTED_CNT=15,
    FEC_PACKET_UNCORRECTABLE_CNT=16,
    DISTORTION_MAX = FEC_PACKET_UNCORRECTABLE_CNT
  } distortion_t;

  /*
   * Deprecated
   */
  const unsigned int NR_OF_DISTORTION_METRICS = (DISTORTION_MAX - DISTORTION_MIN) + 1;

#ifdef __cplusplus
}
#endif

#endif
