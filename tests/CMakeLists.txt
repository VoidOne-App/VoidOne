add_executable(voidone_core_tests
    test_database.cpp
    test_save_backup_manager.cpp
)

target_link_libraries(voidone_core_tests PRIVATE
    voidone_core
    Qt6::Core
    Qt6::Sql
    Qt6::Test
)

target_compile_features(voidone_core_tests PRIVATE cxx_std_23)

if(MSVC)
    target_compile_options(voidone_core_tests PRIVATE /W4 /WX /permissive- /EHsc)
else()
    target_compile_options(voidone_core_tests PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

add_test(NAME VoidOne.CoreTests COMMAND voidone_core_tests)
set_tests_properties(VoidOne.CoreTests PROPERTIES TIMEOUT 120)
