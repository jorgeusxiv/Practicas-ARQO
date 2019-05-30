--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2018
--
-- Pareja: Javier Martínez Rubio, Jorge Santisteban Rivas
-- Grupo: 1311
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      Instruccion : in std_logic_vector (31 downto 0);
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      Jump : out std_logic; --Señal que indica si hay que hacer un salto
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
   );
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
   constant OP_ADDI    : t_opCode := "001000";
   constant OP_SLTI    : t_opCode := "001010";
   constant OP_J    : t_opCode := "000010";

begin

process(Instruccion)

  begin
    
  if Instruccion = x"00000000" then --NOP
    Branch <= '0';
    Jump <= '0';
    MemToReg <= '0';
    MemWrite <= '0';
    MemRead <= '0';
    ALUSrc <= '0';
    ALUOp <= "000";
    RegWrite <= '0';
    RegDst <= '0';
  else --Si la instruccion no son 32 ceros

    if  OpCode = OP_RTYPE then --R-type
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '0';
      ALUOp <= "000";
      RegWrite <= '1';
      RegDst <= '1';

    elsif OpCode = OP_LW then --lw
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '1';
      MemWrite <= '0';
      MemRead <= '1';
      ALUSrc <= '1';
      ALUOp <= "001";
      RegWrite <= '1';
      RegDst <= '0';

    elsif OpCode = OP_SW then --sw
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';
      MemWrite <= '1';
      MemRead <= '0';
      ALUSrc <= '1';
      ALUOp <= "001";
      RegWrite <= '0';
      RegDst <= '0'; 

    elsif OpCode = OP_BEQ then --beq
      Branch <= '1';
      Jump <= '0';
      MemToReg <= '0'; 
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '0';
      ALUOp <= "010";
      RegWrite <= '0';
      RegDst <= '0'; 

    elsif OpCode = OP_ADDI then --addi, 
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '1';
      ALUOp <= "001";
      RegWrite <= '1';
      RegDst <= '0';

    elsif OpCode = OP_LUI then --lui
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';  
      MemWrite <= '0';
      MemRead <= '0'; 
      ALUSrc <= '1';  
      ALUOp <= "011"; 
      RegWrite <= '1';
      RegDst <= '0';
      
    elsif OpCode = OP_SLTI then --slti
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '1';
      ALUOp <= "100"; 
      RegWrite <= '1';
      RegDst <= '0';
      
    elsif OpCode = OP_J then --j
      Branch <= '0';
      Jump <= '1';
      MemToReg <= '0';
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '0';
      ALUOp <= "010";
      RegWrite <= '0';
      RegDst <= '0';
      
  else --en cualquier otro caso, ponemos todas las señales a 0 por defecto.
      Branch <= '0';
      Jump <= '0';
      MemToReg <= '0';
      MemWrite <= '0';
      MemRead <= '0';
      ALUSrc <= '0';
      ALUOp <= "000";
      RegWrite <= '0';
      RegDst <= '0';
    end if;
  end if;
end process;

end architecture;
