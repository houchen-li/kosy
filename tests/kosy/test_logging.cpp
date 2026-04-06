/**
 * @file test_logging.cpp
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief doctest smoke test for kosy logging API.
 * @version 0.1
 * @date 2026-08-20
 *
 * @copyright Copyright (c) 2026 Kosy Development Team
 *            All rights reserved.
 *
 */

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest/doctest.h"

#include "kosy/utils/logging.hpp"

TEST_CASE("logTrace/logDebug/logInfo/logWarn/logError/logCritical compile and run") {
    kosy::logTrace("trace message {}", 1);
    kosy::logDebug("debug message {}", 2);
    kosy::logInfo("info message {}", 3);
    kosy::logWarn("warn message {}", 4);
    kosy::logError("error message {}", 5);
    kosy::logCritical("critical message {}", 6);

    kosy::Logger* const default_logger{spdlog::default_logger_raw()};
    kosy::logInfo(default_logger, "info message with explicit logger {}", 7);

    CHECK(true);
}
