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

    --Señales necesarias para la segmentacion
      --IF/ID
      signal PC4ID : std_logic_vector(31 downto 0);
      signal IDataInID : std_logic_vector(31 downto 0);

      --ID/EX
      signal PC4EX : std_logic_vector(31 downto 0);
      signal Rd1EX : std_logic_vector(31 downto 0);
      signal Rd2EX : std_logic_vector(31 downto 0);
      signal ExtSigEX : std_logic_vector(31 downto 0);
      signal I2016EX : std_logic_vector(4 downto 0);
      signal I1511EX : std_logic_vector(4 downto 0);
      signal RegDstEX : std_logic;
      signal BranchEX : std_logic;
      signal MemReadEX : std_logic;
      signal MemToRegEX : std_logic;
      signal AluOpEX : std_logic_vector(2 downto 0);
      signal MemWriteEX : std_logic;
      signal ALUSrcEX : std_logic;
      signal RegWriteEX : std_logic;
      signal JumpEX : std_logic;
      signal PcSrcEX : std_logic;

      --EX/MEM
      signal BTAMEM : std_logic_vector(31 downto 0);
      signal ZeroMEM : std_logic;
      signal ResMEM : std_logic_vector (31 downto 0);
      signal Rd2MEM : std_logic_vector(31 downto 0);
      signal A3MEM : std_logic_vector(4 downto 0);
      signal BranchMEM : std_logic;
      signal MemReadMEM : std_logic;
      signal MemToRegMEM : std_logic;
      signal MemWriteMEM : std_logic;
      signal RegWriteMEM : std_logic;
      signal JumpMEM : std_logic;

      --MEM/WB
      signal MemToRegWB : std_logic;
      signal RegWriteWB : std_logic;
      signal JumpWB : std_logic;
      signal A3WB : std_logic_vector(4 downto 0);
      signal ResWB : std_logic_vector (31 downto 0);
      signal DDataInWB : std_logic_vector (31 downto 0);

      --Enables
      signal Enable_IF_ID : std_logic;
      signal Enable_ID_EX : std_logic;
      signal Enable_EX_MEM : std_logic;
      signal Enable_MEM_WB : std_logic;

   begin
	
  	--Hacemos los mapeos correspondientes
	REG_B : reg_bank port map(
		Clk  => Clk,
     		Reset =>Reset,
    		A1 => IDataInID(25 downto 21),
     		Rd1 => Rd1Aux,
     		A2 => IDataInID(20 downto 16),
     		Rd2 => Rd2Aux,
     		A3 => A3WB,
     		Wd3 => Wd3Aux,
     		We3 => RegWriteWB
	);


	ALU_MIPS : alu port map(
		OpA => Rd1EX,
     		OpB => RegAluMuxAux,
     		Control => AluControlAux,
     		Result  => ResAux,
     		ZFlag => ZeroAux
	);

	
	ALU_CONTR : alu_control port map(
		ALUOp => ALUOpEX,
      		Funct => ExtSigEX(5 downto 0),
      		ALUControl => ALUControlAux
	);


	CONTR_UNIT : control_unit port map(
      		Instruccion => IDataInID,
      		OpCode  => IDataInID(31 downto 26),
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

	--Enables
	Enable_IF_ID <= '1';
	Enable_ID_EX <= '1';
	Enable_EX_MEM <= '1';
	Enable_MEM_WB <= '1';

	-- En primer lugar actualizamos el PC

	process(Clk, Reset)
		
	begin

		if Reset = '1' then PcAux <= (others => '0');

		elsif rising_edge(Clk) then PcAux <= PcMuxAux;

		end if;

	end process;

  --Proceso del IF/ID

    IF_ID: 
    Process(Clk, Reset)
    begin
      if Reset = '1' then
        PC4ID <= (others => '0');
        IDataInID <= (others => '0');

      elsif rising_edge(Clk) and Enable_IF_ID = '1' then
        PC4ID <= Pc4Aux;
        IDataInID <= IDataIn;
      end if;
    end process;

  --Proceso del ID/EX

    ID_EX:
    Process(Clk, Reset)
    begin
      if Reset = '1' then
        PC4EX <= (others => '0');
        Rd1EX <= (others => '0');
        Rd2EX <= (others => '0');
        ExtSigEX <= (others => '0');
        I2016EX <= (others => '0');
        I1511EX <= (others => '0');
        RegDstEX <= '0';
        BranchEX <= '0';
        MemReadEX <= '1';
        MemToRegEX <= '0';
        AluOpEX <= (others => '0');
        MemWriteEX <= '0';
        ALUSrcEX <= '0';
        RegWriteEX <= '0';
        JumpEX <= '0';
        PcSrcEX <= '0';

       elsif rising_edge(Clk) and Enable_ID_EX = '1' then
        PC4EX <= PC4ID;
        Rd1EX <= Rd1Aux;
        Rd2EX <= Rd2Aux;
        ExtSigEX <= ExtSigAux;
        I2016EX <= IDataInID(20 downto 16);
        I1511EX <= IDataInID(15 downto 11);
        RegDstEX <= RegDstAux;
        BranchEX <= BranchAux;
        MemReadEX <= MemReadAux;
        MemToRegEX <= MemToRegAux;
        AluOpEX <= AluOpAux;
        MemWriteEX <= MemWriteAux;
        ALUSrcEX <= ALUSrcAux;
        RegWriteEX <= RegWriteAux;
        JumpEX <= JumpAux;
        PcSrcEX <= PcSrcAux;
      end if;
    end process;

  --Proceso del EX/MEM

    EX_MEM:
    Process(Clk, Reset)
    begin
      if reset ='1' then
        BTAMEM <= (others => '0');
        ZeroMEM <= '0';
        ResMEM <= (others => '0');
        Rd2MEM <= (others => '0');
        A3MEM <= (others => '0');
        BranchMEM <= '0';
        MemReadMEM <= '1';
        MemToRegMEM <= '0';
        MemWriteMEM <= '0';
        RegWriteMEM <= '0';
        JumpMEM <= '0';
      elsif rising_edge(Clk) and Enable_EX_MEM = '1' then
        BTAMEM <= BTAAux;
        ZeroMEM <= ZeroAux;
        ResMEM <= ResAux;
        Rd2MEM <= Rd2EX;
        A3MEM <= A3Aux;
        BranchMEM <= BranchEX;
        MemReadMEM <= MemReadEX;
        MemToRegMEM <= MemToRegEX;
        MemWriteMEM <= MemWriteEX;
        RegWriteMEM <= RegWriteEX;
        JumpMEM <= JumpEX;
      end if;
    end process;

  --Proceso del MEM/WB
    MEM_WB:
    Process(Clk, Reset)
    begin 
      if reset ='1' then
        MemToRegWB <= '0';
        RegWriteWB <= '0';
        JumpWB <= '0';
        A3WB <= (others => '0');
        ResWB <= (others => '0');
        DDataInWB <= (others => '0');
      elsif rising_edge(Clk) and Enable_MEM_WB = '1' then
        MemToRegWB <= MemToRegMEM;
        RegWriteWB <= RegWriteMEM;
        JumpWB <= JumpMEM;
        A3WB <= A3MEM;
        ResWB <= ResMEM;
        DDataInWB <= DDataIn;
      end if;
    end process;


	-- Asignamos el PC+4, el JTA y el BTA

	Pc4Aux <= PcAux + 4;
	BTAAux <= PC4EX + (ExtSigEX(29 downto 0) & "00");
	JTAAux <= PC4ID(31 downto 28) & IDataInID(25 downto 0) & "00";

	-- Definimos PCSrc (Un AND entre Zero y Branch)

	PcSrcAux <= BranchMEM and ZeroMEM;

	-- Definimos el extensor de signo

	ExtSigAux(31 downto 16) <= (others => IDataInID(15));
	ExtSigAux(15 downto 0) <= IDataInID(15 downto 0);


	-- Definimos los multiplexores

	A3Aux <= I2016EX when RegDstEX = '0' else I1511EX;

	RegAluMuxAux <= ExtSigEX when ALUSrcEX = '1' else Rd2EX;

	Wd3Aux <= ResWB when MemToRegWB = '0' else DDataInWB;
	
	PcMuxAux <= BTAMEM when JumpWB = '0' and PcSrcAux = '1' else
		    Pc4Aux when JumpWB = '0' and PcSrcAux = '0' else
		    JTAAux;

	
	-- Acabamos de conectar los componentes del microprocesador

	DRdEn <= MemReadMEM;
	DWrEn <= MemWriteMEM;
	DDataOut <= Rd2MEM;
	IAddr <= PcAux;
	DAddr <= ResMEM;

	


end architecture;
