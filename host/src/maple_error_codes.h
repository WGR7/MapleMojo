#ifndef MAPLE_ERROR_CODES_H_
#define MAPLE_ERROR_CODES_H_

#include "maple_status.h"

#define MAPLE_OK 0

/* Error codes from Maple device */

#define MAPLE_ERROR_FUNCTION_CODE_UNSUPPORTED      -2
#define MAPLE_ERROR_UNKNOWN_COMMAND                -3
#define MAPLE_ERROR_SAY_AGAIN                      -4
#define MAPLE_ERROR_FILE_ERROR                     -5

/* Error codes from host layer */

#define MAPLE_ERROR_PAYLOAD_TOO_LARGE              -129
#define MAPLE_ERROR_PAYLOAD_SIZE_MISMATCH          -130
#define MAPLE_ERROR_INTERNAL_READ_STATUS_FAILURE   -131
#define MAPLE_ERROR_INTERNAL_READ_HEADER_FAILURE   -132
#define MAPLE_ERROR_INTERNAL_WRITE_FAILURE         -133
#define MAPLE_ERROR_INTERNAL_READ_PAYLOAD_FAILURE  -134
#define MAPLE_ERROR_INTERNAL_READ_CHECKSUM_FAILURE -135
#define MAPLE_ERROR_CHECKSUM_MISMATCH              -136
#define MAPLE_ERROR_UNEXPECTED_RESPONSE            -137
#define MAPLE_ERROR_INVALID_RESPONSE_LENGTH        -138
#define MAPLE_ERROR_OUT_OF_MEMORY                  -139
#define MAPLE_ERROR_BAD_ARGUMENT                   -140
#define MAPLE_ERROR_SUBUNIT_DOES_NOT_EXIST         -141
#define MAPLE_ERROR_INVALID_NEXT_FAT_ENTRY         -142
#define MAPLE_ERROR_NO_MORE_DIR_ENTRIES            -143

/* Error codes from microcontroller layer */

#define MAPLE_STATUS_TO_ERROR(s) (-512|(s))

#define MAPLE_ERROR_NO_START_PATTERN  MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_NO_START_PATTERN)
#define MAPLE_ERROR_FIFO_OVERFLOW     MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_FIFO_OVERFLOW)
#define MAPLE_ERROR_FIFO_UNDERFLOW    MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_FIFO_UNDERFLOW)
#define MAPLE_ERROR_REPLY_TOO_LONG    MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_REPLY_TOO_LONG)
#define MAPLE_ERROR_TIMEOUT           MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_TIMEOUT)
#define MAPLE_ERROR_REPLY_TOO_SHORT   MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_REPLY_TOO_SHORT)
#define MAPLE_ERROR_REPLY_BAD_COUNT   MAPLE_STATUS_TO_ERROR(MAPLE_STATUS_REPLY_BAD_COUNT)

#endif /* MAPLE_ERROR_CODES_H_ */
