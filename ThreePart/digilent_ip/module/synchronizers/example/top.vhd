----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2022 05:43:57 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library xpm;
use xpm.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( OneClk : in STD_LOGIC;
           TwoClk : in STD_LOGIC;
           aSignal : in STD_LOGIC;
           atRstPos : out STD_LOGIC;
           atRstNeg : out STD_LOGIC;
           atRstXPMPos : out STD_LOGIC;
           atRstXPMNeg : out STD_LOGIC;
           tSignal : out STD_LOGIC;
           tSignalHs : out STD_LOGIC;
           oPush : in STD_LOGIC;
           oRdy : out STD_LOGIC;
           tValid : out STD_LOGIC);
end top;

architecture Behavioral of top is

signal aoRst, oSignal, oSignalXPM, aoRstPos, atRstPos_int : std_logic;
signal oSignalVect : std_logic_vector(0 downto 0);
signal tSignalVect : std_logic_vector(0 downto 0);

begin

oSignalVect(0) <= oSignal;
tSignalHs <= tSignalVect(0);

SyncAsync1: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 3) --use double FF synchronizer
   port map (
      aoReset => aoRstPos,
      aIn => aSignal,
      OutClk => OneClk,
      oOut => oSignal);

SyncBase: entity work.SyncBase
generic map (
      kResetTo => '0',
      kStages => 3) --use double FF synchronizer
   port map (
      aiReset => '0',
      InClk => OneClk,
      iIn => oSignal,
      aoReset => '0',
      OutClk => TwoClk,
      oOut => tSignal);


ResetBridgePos: entity work.ResetBridge
   Generic map (
      kPolarity => '1')
   Port map (
      aRst => oSignal,
      OutClk => TwoClk,
      aoRst => atRstPos_int
   );
atRstPos <= atRstPos_int;

ResetBridgeBack: entity work.ResetBridge
   Generic map (
      kPolarity => '1')
   Port map (
      aRst => atRstPos_int,
      OutClk => OneClk,
      aoRst => aoRstPos
   );

ResetBridgeNeg: entity work.ResetBridge
   Generic map (
      kPolarity => '0')
   Port map (
      aRst => oSignal,
      OutClk => TwoClk,
      aoRst => atRstNeg
   );

HandshakeData: entity work.HandshakeData
    Generic map(
        kDataWidth => 1)
    Port map(
        InClk => OneClk,
        OutClk => TwoClk,
        iData => oSignalVect,
        oData => tSignalVect,
        iPush => oPush,
        iRdy => oRdy,
        oValid => tValid,
        aiReset => '0',
        aoReset => '0'
    );


-- <-----Cut code below this line and paste into the architecture body---->

   -- xpm_cdc_async_rst: Asynchronous Reset Synchronizer
   -- Xilinx Parameterized Macro, version 2021.1

--   xpm_cdc_async_rst_pos : xpm_cdc_async_rst
--   generic map (
--      DEST_SYNC_FF => 2,    -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 0,    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      RST_ACTIVE_HIGH => 1  -- DECIMAL; 0=active low reset, 1=active high reset
--   )
--   port map (
--      dest_arst => atRstXPMPos, -- 1-bit output: src_arst asynchronous reset signal synchronized to destination
--                              -- clock domain. This output is registered. NOTE: Signal asserts asynchronously
--                              -- but deasserts synchronously to dest_clk. Width of the reset signal is at least
--                              -- (DEST_SYNC_FF*dest_clk) period.

--      dest_clk => TwoClk,   -- 1-bit input: Destination clock.
--      src_arst => oSignal    -- 1-bit input: Source asynchronous reset signal.
--   );

--   xpm_cdc_async_rst_neg : xpm_cdc_async_rst
--   generic map (
--      DEST_SYNC_FF => 2,    -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 0,    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      RST_ACTIVE_HIGH => 0  -- DECIMAL; 0=active low reset, 1=active high reset
--   )
--   port map (
--      dest_arst => atRstXPMNeg, -- 1-bit output: src_arst asynchronous reset signal synchronized to destination
--                              -- clock domain. This output is registered. NOTE: Signal asserts asynchronously
--                              -- but deasserts synchronously to dest_clk. Width of the reset signal is at least
--                              -- (DEST_SYNC_FF*dest_clk) period.

--      dest_clk => TwoClk,   -- 1-bit input: Destination clock.
--      src_arst => oSignal    -- 1-bit input: Source asynchronous reset signal.
--   );

--   xpm_cdc_single_inst : xpm_cdc_single
--   generic map (
--      DEST_SYNC_FF => 2,   -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
--      SRC_INPUT_REG => 0   -- DECIMAL; 0=do not register input, 1=register input
--   )
--   port map (
--      dest_out => oSignalXPM, -- 1-bit output: src_in synchronized to the destination clock domain. This output
--                            -- is registered.

--      dest_clk => OneClk, -- 1-bit input: Clock signal for the destination clock domain.
--      src_clk => '1',   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
--      src_in => aSignal      -- 1-bit input: Input signal to be synchronized to dest_clk domain.
--   );
end Behavioral;
