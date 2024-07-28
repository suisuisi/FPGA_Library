/*-------------------------------------------------------------------------
 Testbench for RSA Macro (ASIC version)
                                   
 File name   : RSA_tb.v
 Version     : Version 1.0
 Created     : 
 Last update : SET/25/2007
 Desgined by : Atsushi Miyamoto
 

 Copyright (C) 2007 AIST and Tohoku Univ.
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST and Tohoku University ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our webpage
 (http://www.aoki.ecei.tohoku.ac.jp/crypto/).
 -------------------------------------------------------------------------*/ 

`timescale 1ns/1ns

module RSA_tb;
   reg        CLK, RSTn;
   reg        Drdy, Mrdy, Krdy;
   reg [31:0] Kin, Min, Din;

   wire [31:0] Dout;
   wire        BSY, Kvld, Mvld, Dvld;

   integer     i;

   reg 	       ANS_OUT;
      
   RSA RSA (// Outputs
	    .Dout	(Dout[31:0]),
	    .BSY       (BSY),
	    .Dvld      (Dvld),
	    .Mvld      (Mvld),
	    .Kvld      (Kvld),
	    // Inputs
	    .CLK       (CLK),
	    .EN        (1'b1),
	    .RSTn      (RSTn),
	    .Drdy      (Drdy),
	    .Mrdy      (Mrdy),
	    .Krdy      (Krdy),
	    .Kin       (Kin[31:0]),
	    .Min       (Min[31:0]),
	    .Din       (Din[31:0]));
   

   // Test-vectors
   // 1024 bit data ////////////////////////////////////////////////////
   parameter   KEY = 1024'h3d90583967fa0eb0c094be7364566069671dbd6b227894950c799eb6df85016e69a73707911072dc79306d7b7c39d17b91b093738a767095bfc2f0c9101d46e9f5c6223bcec81fbedf27daa04435d5e862edf78af08df2e80e0d848d31d1bc330d0c7eab45fe47935cbb2205532025522886872ff402809f5f90bc842c665d59;
   parameter   MOD = 1024'he33f163d5abb6400570f33f1b25c2f2c971fd4105c60de34bb24aaf5c751996c51f5ba457738cb26c5d326cb1bc7af83ee0a9994e35e3894e8b60b438cbcc0cbaa9b0f068b87c2b254024d33b2e8a927471f65e96bdb59979d1cbee8f9da1ec9c3ffc485169443b0c21571d8e2cf318ecf70c65159268afe2e53ed42cdc830d3;
   parameter   PT  = 1024'hceba9238407ed1645c01d7a77e2db31946f16faa0778db7dfe205dc4ba6514021d59a408800cac7984c68e4157181a98c44028162d8aee2095b4d1e63392f980816881f87cc4866ad06b449ce990f8a9e459a1c9398181dd9296230bdb7e288c5b41a4fbb2686c0318d03b4b1af7640fa0471f0370fff32fc6f760cab80b0acd;
   
   // output : 775a0a0f1660d75a4072bfe624333f953821f6a4a797817bfa664e10b430707e968719a59e625710c569d5616b1b375afaf4100453d5077d69cbb7cf5e8f078d24d77200d9cc19bcbda19b274aa6788479dfb89f5f9136e9ef06907b61839a104180bc350928f547fdb25fdb04fa4744f6bcb71d9b21f7733797ea0add86c0cc

   // 512 bit data ////////////////////////////////////////////////////
   //parameter   KEY = 1024'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fefd276150df47b1d075839b70724afed712aea6281b93fa756851e5b74ac80731e66ef0a6fa222d9cc494852e8e87e5677dc5f1cef2a636067992c4ccb9f97;
   //parameter   MOD = 1024'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080631314bf07d95fafa253bc7fcf30f0554e8b3716365661b051893f45afd657c9b9a417c94fb1f2f4e68646080ef30c1fc9c847db2f1f36458fcc32128aad41;
   //parameter   PT  = 1024'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003d5b81622c05ada8f6a80f1608453984462d53226303a89febb24db60db3c0913051ba49cbc8429af57e9783c7f59cef12c138c783a3daef2d362ac39afd9ba9;
   
   // out put : 56A08CFD415CB51715F4AA89B2CD5F8A000D72C105EA776373F0E96A378F9CA94AB07ACEF0FACEF06B447291855B6E8242170AFA15AEF178E293DCAAD4827766
   
   // 256 bit data ////////////////////////////////////////////////////
   //parameter KEY = 1024'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041F1EF580200931E855704AC644A0A392A6D58CC0C06F9F7D45F74792175838D;
   //parameter MOD = 1024'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000BF59E34F0F02F2940E20E9DEFCC5FC9A971776A79C00965796AD199E1ECD470B;
   //parameter PT  = 1024'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004C816CC95B3FF6D53FBC4B3FFD1881D06C18E8974B790749A26124F760025ED2;

   // output: 6305F7E81B25749B56042684F3C6F6B01FCC97D77519D153BCCB125806C85D3A
  
   parameter   PERIOD = 50;
   
   initial
     begin
	CLK <= 1'b1;
	RSTn <= 1'b0;
	Drdy <= 1'b0;
	Mrdy <= 1'b0;
	Krdy  <= 1'b0;

	#(PERIOD*2);
	#(PERIOD/2) RSTn <= 1'b0;
	#(PERIOD) RSTn <= 1'b1;

	// Key set
	#(PERIOD*2) Krdy <= 1'b1;
	#(PERIOD) Krdy <= 1'b0; 
	          Kin <= KEY[31:0];
	#(PERIOD) Kin <= KEY[63:32];
	#(PERIOD) Kin <= KEY[95:64];
	#(PERIOD) Kin <= KEY[127:96];
	#(PERIOD) Kin <= KEY[159:128];
	#(PERIOD) Kin <= KEY[191:160];
	#(PERIOD) Kin <= KEY[223:192];
	#(PERIOD) Kin <= KEY[255:224];
	#(PERIOD) Kin <= KEY[287:256];
	#(PERIOD) Kin <= KEY[319:288];
	#(PERIOD) Kin <= KEY[351:320];
	#(PERIOD) Kin <= KEY[383:352];
	#(PERIOD) Kin <= KEY[415:384];
	#(PERIOD) Kin <= KEY[447:416];
	#(PERIOD) Kin <= KEY[479:448];
	#(PERIOD) Kin <= KEY[511:480];
	#(PERIOD) Kin <= KEY[543:512];
	#(PERIOD) Kin <= KEY[575:544];
	#(PERIOD) Kin <= KEY[607:576];
	#(PERIOD) Kin <= KEY[639:608];
	#(PERIOD) Kin <= KEY[671:640];
	#(PERIOD) Kin <= KEY[703:672];
	#(PERIOD) Kin <= KEY[735:704];
	#(PERIOD) Kin <= KEY[767:736];
	#(PERIOD) Kin <= KEY[799:768];
	#(PERIOD) Kin <= KEY[831:800];
	#(PERIOD) Kin <= KEY[863:832];
	#(PERIOD) Kin <= KEY[895:864];
	#(PERIOD) Kin <= KEY[927:896];
	#(PERIOD) Kin <= KEY[959:928];
	#(PERIOD) Kin <= KEY[991:960];
	#(PERIOD) Kin <= KEY[1023:992];

	// Mod set
	#(PERIOD*4) Mrdy <= 1'b1;
	#(PERIOD) Mrdy <= 1'b0;
	          Min <= MOD[31:0];
	#(PERIOD) Min <= MOD[63:32];
	#(PERIOD) Min <= MOD[95:64];
	#(PERIOD) Min <= MOD[127:96];
	#(PERIOD) Min <= MOD[159:128];
	#(PERIOD) Min <= MOD[191:160];
	#(PERIOD) Min <= MOD[223:192];
	#(PERIOD) Min <= MOD[255:224];
	#(PERIOD) Min <= MOD[287:256];
	#(PERIOD) Min <= MOD[319:288];
	#(PERIOD) Min <= MOD[351:320];
	#(PERIOD) Min <= MOD[383:352];
	#(PERIOD) Min <= MOD[415:384];
	#(PERIOD) Min <= MOD[447:416];
	#(PERIOD) Min <= MOD[479:448];
	#(PERIOD) Min <= MOD[511:480];
	#(PERIOD) Min <= MOD[543:512];
	#(PERIOD) Min <= MOD[575:544];
	#(PERIOD) Min <= MOD[607:576];
	#(PERIOD) Min <= MOD[639:608];
	#(PERIOD) Min <= MOD[671:640];
	#(PERIOD) Min <= MOD[703:672];
	#(PERIOD) Min <= MOD[735:704];
	#(PERIOD) Min <= MOD[767:736];
	#(PERIOD) Min <= MOD[799:768];
	#(PERIOD) Min <= MOD[831:800];
	#(PERIOD) Min <= MOD[863:832];
	#(PERIOD) Min <= MOD[895:864];
	#(PERIOD) Min <= MOD[927:896];
	#(PERIOD) Min <= MOD[959:928];
	#(PERIOD) Min <= MOD[991:960];
	#(PERIOD) Min <= MOD[1023:992];

	// Plain text set 
	#(PERIOD*4) Drdy <= 1'b1;
	#(PERIOD) Drdy <= 1'b0;
	          Din <= PT[31:0];
	#(PERIOD) Din <= PT[63:32];
	#(PERIOD) Din <= PT[95:64];
	#(PERIOD) Din <= PT[127:96];
	#(PERIOD) Din <= PT[159:128];
	#(PERIOD) Din <= PT[191:160];
	#(PERIOD) Din <= PT[223:192];
	#(PERIOD) Din <= PT[255:224];
	#(PERIOD) Din <= PT[287:256];
	#(PERIOD) Din <= PT[319:288];
	#(PERIOD) Din <= PT[351:320];
	#(PERIOD) Din <= PT[383:352];
	#(PERIOD) Din <= PT[415:384];
	#(PERIOD) Din <= PT[447:416];
	#(PERIOD) Din <= PT[479:448];
	#(PERIOD) Din <= PT[511:480];
	#(PERIOD) Din <= PT[543:512];
	#(PERIOD) Din <= PT[575:544];
	#(PERIOD) Din <= PT[607:576];
	#(PERIOD) Din <= PT[639:608];
	#(PERIOD) Din <= PT[671:640];
	#(PERIOD) Din <= PT[703:672];
	#(PERIOD) Din <= PT[735:704];
	#(PERIOD) Din <= PT[767:736];
	#(PERIOD) Din <= PT[799:768];
	#(PERIOD) Din <= PT[831:800];
	#(PERIOD) Din <= PT[863:832];
	#(PERIOD) Din <= PT[895:864];
	#(PERIOD) Din <= PT[927:896];
	#(PERIOD) Din <= PT[959:928];
	#(PERIOD) Din <= PT[991:960];
	#(PERIOD) Din <= PT[1023:992];

	#(PERIOD*7100000) $finish;
     end

   always #(PERIOD/2)
     CLK <= ~CLK;

   always @(posedge CLK) begin
      if (RSTn == 1'b0)
	ANS_OUT <= 1'b0;
      else if (Dvld == 1'b1)
	ANS_OUT <= 1'b1;
   end
   
   always @(posedge CLK) begin
      // output
      if (ANS_OUT == 1'b1) begin
	 $display( $stime, "  Dout=%h Dvld=%b", Dout, Dvld);
      end
   end   

endmodule









