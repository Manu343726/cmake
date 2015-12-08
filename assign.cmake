
macro(ASSIGN_OR_DEFAULT TO FROM DEFAULT)
	if(FROM)
		set(${TO} ${FROM})
	else()
		set(${TO} ${DEFAULT})
	endif()
endmacro()