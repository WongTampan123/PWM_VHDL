library ieee;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity pwm_core is
	port(
	clk: in std_logic;
	duty_in: in unsigned (7 downto 0);
	sg: in std_logic_vector(2 downto 0);
	pwm_out: out std_logic
	);
end pwm_core;

architecture behavioral of pwm_core is
	constant POSEDGE_256kHz : std_logic := '0';
	constant NEGEDGE_256kHz : std_logic := '1';
	constant POSEDGE 			: std_logic := '0';
	constant NEGEDGE 			: std_logic := '1';
	
	signal state_256kHz		: std_logic:='0';
	signal state				: std_logic:='0';
	
	signal duty_cycle			: unsigned (8 downto 0):=to_unsigned(0,9);
	signal count				: unsigned (8 downto 0):=to_unsigned(0,9);
	signal count_pwm			: unsigned (8 downto 0):=to_unsigned(0,9);
	signal clk_256kHZ			: std_logic := '0';
	signal pwm_reg				: std_logic := '0';
begin
duty_cycle(7 downto 0)<=duty_in;

--duty_cycle(7 downto 0)<="11111111";
	process(clk) begin
	if(rising_edge(clk)) then
		case state_256kHz is
			when POSEDGE_256kHz =>
				if (count=to_unsigned(98,9)) then
					clk_256kHz	<='0';
					count			<=count+1;
					state_256kHz<=NEGEDGE_256kHz;
				else 
					clk_256kHz	<='1';
					count			<=count+1;
					state_256kHz<=POSEDGE_256kHz;
				end if;
			when NEGEDGE_256kHz =>
				if (count=to_unsigned(195,9)) then
					clk_256kHz	<='1';
					count			<=to_unsigned(0,9);
					state_256kHz<=POSEDGE_256kHz;
				else
					clk_256kHz	<='0';
					count			<=count+1;
					state_256kHz<=NEGEDGE_256kHz;
				end if;
			when others =>
			end case;
	end if;
	end process;
	
	process(clk_256kHz) begin
	if (rising_edge(clk_256kHz)) then
			case state is
				when POSEDGE =>
					if(count_pwm=duty_cycle) then
						pwm_reg	<='0';
						count_pwm<=count_pwm+1;
						state		<=NEGEDGE;
					elsif (count_pwm>=duty_cycle) then
						count_pwm<=to_unsigned(0,9);
						state		<=POSEDGE;
					else
						pwm_reg	<='1';
						count_pwm<=count_pwm+1;
						state		<=POSEDGE;
					end if;
				when NEGEDGE =>
					if(count_pwm=to_unsigned(256,9)) then
						pwm_reg	<='1';
						count_pwm<=to_unsigned(0,9);
						state		<=POSEDGE;
					else
						pwm_reg	<='0';
						count_pwm<=count_pwm+1;
						state		<=NEGEDGE;
					end if;
				when others =>
				
				end case;
		end if;		
	end process;
pwm_out<=pwm_reg;
end behavioral;
	