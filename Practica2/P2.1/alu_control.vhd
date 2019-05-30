--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2018.
--
-- Pareja: Javier Martínez Rubio, Jorge Santisteban Rivas
-- Grupo: 1311
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is
   
begin
  
process(ALUOp, Funct)
  
begin
    
if ALUOp = "000" then 
    
  if Funct = "100101" then --or
    ALUControl <= "0111";
      
  elsif Funct = "100110" then --xor
    ALUControl <= "0110";
      
  elsif Funct = "100100" then --and
    ALUControl <= "0100";
      
  elsif Funct = "100010" then --sub
    ALUControl <= "0001";
      
  elsif Funct = "100000" then --add
    ALUControl <= "0000";
    
  elsif Funct = "101010" then --slt
    ALUControl <= "1010";
  

end if;
      
elsif ALUOp = "001" then -- lw, sw,addi y jump
    
  ALUControl <= "0000";
    
elsif ALUOp = "010" then -- beq
    
  ALUControl <= "0001";
 
elsif ALUOp = "011" then --lui
    ALUControl <= "1101"; 

elsif ALUOp = "100" then --slti
    ALUControl <= "1010";  

end if;         
      
end process;
      

end architecture;
