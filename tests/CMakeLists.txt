add_executable(hello hello.cpp)
# target_link_libraries(hello PRIVATE whatever_library_I_want)
enable_testing()
add_test(NAME "my first test"
	COMMAND hello
)
