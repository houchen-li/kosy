kosy_cxx_test(
  NAME
    test_polynomial
  SRCS
    test_polynomial.cpp
  DEPS
    polynomial
)

kosy_cxx_test(
  NAME
    test_vecadd
  SRCS
    test_vecadd.cpp
  DEPS
    aligned_memory_resource
    vecadd
)

kosy_cxx_test(
  NAME
    test_matmul
  SRCS
    test_matmul.cpp
  DEPS
    aligned_memory_resource
    matmul
)

kosy_cxx_test(
  NAME
    test_logging
  SRCS
    test_logging.cpp
  DEPS
    logging
)
