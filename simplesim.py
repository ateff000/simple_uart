import os
from sys import platform

if platform == 'linux':
	iverilog = 'iverilog'
	vvp = 'vvp'
	gtkwave = 'gtkwave'

elif platform == "win32":	
	iverilog = r'd:\Other\iverilog\bin\iverilog.exe'
	vvp = r'd:\Other\iverilog\bin\vvp.exe'
	gtkwave = r'd:\Other\iverilog\gtkwave\bin\gtkwave.exe'


# testbench = 'TB_UART_TX.v'
# tested = 'UART_TX.v'

testbench = 'TB_UART_RX.v'
tested = 'UART_RX.v'

# testbench = 'TB_FREQ_DIV.v'
# tested = 'FREQ_DIV.v'


output = 'qqq'


# cmd_compil = f'{iverilog} -o {output} {testbench} {tested}'
cmd_compil = f'{iverilog} -o {output} {tested} {testbench}'
cmd_sim = f'{vvp} {output}'


os.system(cmd_compil)
os.system(cmd_sim)


while True:
	command = input('>>>')
	if command == 'exit':
		break
	if command == 'run':
		os.system(cmd_compil)
		os.system(cmd_sim)

