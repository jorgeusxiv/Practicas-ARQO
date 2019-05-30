--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2018-19
--
-- Pareja: Javier Martínez Rubio, Jorge Santisteban Rivas
-- Grupo: 1311
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is
  
  component reg_bank port(
     Clk   : in std_logic; -- Reloj activo en flanco de subida
     Reset : in std_logic; -- Reset asíncrono a nivel alto
     A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
     Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
     A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
     Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
     A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
     Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
     We3   : in std_logic -- Habilitación de la escritura de Wd3
     );
  end component;
  
  component alu port(
     OpA     : in  std_logic_vector (31 downto 0); -- Operando A
     OpB     : in  std_logic_vector (31 downto 0); -- Operando B
     Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
     Result  : out std_logic_vector (31 downto 0); -- Resultado
     ZFlag   : out std_logic                       -- Flag Z
     );
  end component;
  
  component alu_control port(
     -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
     );
  end component;
  
  component control_unit port(
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
  end component;
  
  --Declaramos todas las señales auxiliares necesarias
    
    --ALU
      signal ResAux : std_logic_vector(31 downto 0);
      signal ZeroAux: std_logic;
      
    -- Unidad de control
      signal RegDstAux : std_logic;
      signal BranchAux : std_logic;
      signal MemReadAux : std_logic;
      signal MemToRegAux : std_logic;
      signal AluOpAux : std_logic_vector(2 downto 0);
      signal MemWriteAux : std_logic;
      signal ALUSrcAux : std_logic;
      signal RegWriteAux : std_logic;
      signal JumpAux : std_logic;
      signal PcSrcAux : std_logic;
      
    --ALU Control
      signal AluControlAux : std_logic_vector(3 downto 0);
      
    --Registros
      signal Rd1Aux : std_logic_vector(31 downto 0);
      signal Rd2Aux : std_logic_vector(31 downto 0);
      signal A3Aux : std_logic_vector(4 downto 0);
      signal Wd3Aux : std_logic_vector(31 downto 0);
      
    --Extension de signo
      signal ExtSigAux : std_logic_vector(31 downto 0);
      
    --Multiplexores
      signal RegAluMuxAux : std_logic_vector(31 downto 0);
      signal PcMuxAux : std_logic_vector(31 downto 0);
      
    --Señales auxiliares para el contador
      signal PcAux: std_logic_vector(31 downto 0);
      signal Pc4Aux: std_logic_vector(31 downto 0);
      signal BTAAux: std_logic_vector(31 downto 0);
      signal JTAAux: std_logic_vector(31 downto 0);
  
  begin
	
  	--Hacemos los mapeos correspondientes
	REG_B : reg_bank port map(
		Clk  => Clk,
     		Reset =>Reset,
    		A1 => IDataIn(25 downto 21),
     		Rd1 => Rd1Aux,
     		A2 => IDataIn(20 downto 16),
     		Rd2 => Rd2Aux,
     		A3 => A3Aux,
     		Wd3 => Wd3Aux,
     		We3 => RegWriteAux
	);


	ALU_MIPS : alu port map(
		OpA => Rd1Aux,
     		OpB => RegAluMuxAux,
     		Control => AluControlAux,
     		Result  => ResAux,
     		ZFlag => ZeroAux
	);

	
	ALU_CONTR : alu_control port map(
		ALUOp => ALUOpAux,
      		Funct => IDataIn(5 downto 0),
      		ALUControl => ALUControlAux
	);


	CONTR_UNIT : control_unit port map(
      		Instruccion => IDataIn,
      		OpCode  => IDataIn(31 downto 26),
      		Branch => BranchAux,
      		Jump => JumpAux,
      		MemToReg => MemToRegAux,
      		MemWrite => MemWriteAux,
      		MemRead => MemReadAux,
      		ALUSrc => ALUSrcAux,                 
      		ALUOp => ALUOpAux,
      		RegWrite => RegWriteAux,
      		RegDst => RegDstAux
	);

	-- En primer lugar actualizamos el PC

	process(Clk, Reset)
		
	begin

		if Reset = '1' then PcAux <= (others => '0');

		elsif rising_edge(Clk) then PcAux <= PcMuxAux;

		end if;

	end process;

	-- Asignamos el PC+4, el JTA y el BTA

	Pc4Aux <= PcAux + 4;
	BTAAux <= Pc4Aux + (ExtSigAux(29 downto 0) & "00");
	JTAAux <= Pc4Aux(31 downto 28) & IDataIn(25 downto 0) & "00";

	-- Definimos PCSrc (Un AND entre Zero y Branch)

	PcSrcAux <= BranchAUx and ZeroAux;

	-- Definimos el extensor de signo

	ExtSigAux(31 downto 16) <= (others => IDataIn(15));
	ExtSigAux(15 downto 0) <= IDataIn(15 downto 0);


	-- Definimos los multiplexores

	A3Aux <= IDataIn(20 downto 16) when RegDstAux = '0' else IDataIn(15 downto 11);

	RegAluMuxAux <= ExtSigAux when ALUSrcAux = '1' else Rd2Aux;

	Wd3Aux <= ResAux when MemToRegAux = '0' else DDataIn;
	
	PcMuxAux <= BTAAux when JumpAux = '0' and PcSrcAux = '1' else
		    Pc4Aux when JumpAux = '0' and PcSrcAux = '0' else
		    JTAAux;

	
	-- Acabamos de conectar los componentes del microprocesador

	DRdEn <= MemReadAux;
	DWrEn <= MemWriteAux;
	DDataOut <= Rd2Aux;
	IAddr <= PcAux;
	DAddr <= ResAux;

	


end architecture;
