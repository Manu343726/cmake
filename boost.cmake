
get_filename_component(cmake_project_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(boost_submodule "${cmake_project_dir}/boost")

if(NOT (EXISTS boost_submodule))
	execute_process(
		COMMAND ${GIT_EXECUTABLE} submodule update --init
	)
endif()

set(CMAKEPP_FILE "${cmake_project_dir}/cmakepp.cmake")

include(${boost_submodule}/blocks/boost/install/install.cmake)