bram_file = open("lookup_table.coe", "w")
bram_sim_file = open("lookup_table.dat", "w")

sim_header = "@0000/n"
synth_header = "memory_initialization_radix=16;\nmemory_initialization_vector=\n"

bram_file.write(synth_header)
bram_sim_file.write(sim_header)

for i in range(0,2**11 - 1):
    number = 2**17/(2**11 - i)
    hex_string = hex(int(number))    #convert to a string
    hex_string = hex_string[2:] #remove the "0x"
    bram_file.write(hex_string + ",\n")
    bram_sim_file.write(hex_string + "\n")

#the last value
number = 2**17
hex_string = hex(number)    #convert to a string
hex_string = hex_string[2:] #remove the "0x"
bram_file.write(hex_string)
bram_sim_file.write(hex_string)


