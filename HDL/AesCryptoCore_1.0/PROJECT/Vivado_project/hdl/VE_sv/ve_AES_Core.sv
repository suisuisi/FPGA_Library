/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: AES Class, implemeting High Level Algorithm
// Module Name: AES_Class.sv
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: aes_calculator
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "ve_AES_types.sv"
class AesCore extends BaseUnit;

	int BC, KC, ROUNDS;

	AlreadyComputed computed_val;
	extern function new(string name, int id, ref AlreadyComputed com_val);
	extern function word8 mul(word8 a, word8 b);
	extern function void MixColumn(ref word8 a[4][`MAXBC]);
	extern function void InvMixColumn(ref word8 a[4][`MAXBC]);
	extern function void AddRoundKey(word8 rk[4][`MAXBC], ref word8 a[4][`MAXBC]);
	extern function void SubBytes(word8 box[256], ref word8 a[4][`MAXBC]);
	extern function void ShiftRows(word8 d, ref word8 a[4][`MAXBC]);
	extern function int KeyExpansion(word8 k[4][`MAXBC], ref word8 W[`MAXROUNDS + 1][4][`MAXBC]);
	extern function int Encrypt ( ref word8 a[4][`MAXBC], ref word8 rk[`MAXROUNDS + 1][4][`MAXBC]);
	extern function int Decrypt ( ref word8 a[4][`MAXBC],ref  word8 rk[`MAXROUNDS + 1][4][`MAXBC]);
	extern task run();
	
endclass : AesCore

function AesCore :: new(string name, int id, ref AlreadyComputed com_val);
	super.new(name,id);
	if(com_val == null) begin
         com_val = new();
    end
	this.computed_val = com_val;
endfunction : new

function word8 AesCore :: mul(word8 a, word8 b); 
	word32 temp;
	word8 val;
	if (a && b) begin 
		//temp = computed_val.Alogtable[(computed_val.Logtable[a] + computed_val.Logtable[b]) % 255];
		temp = (computed_val.Logtable[a] + computed_val.Logtable[b]) % 255;
		val =  computed_val.Alogtable[temp];
	end 
	else begin
		temp = 0;
	end
	return val;
endfunction : mul

function void AesCore :: AddRoundKey(word8 rk[4][`MAXBC], ref word8 a[4][`MAXBC]);
	//XOR with the corresponding text from input
	for (int i = 0; i < 4; i++) begin
		for (int j = 0; j < BC; j++) begin
			a[i][j] = a[i][j] ^ rk[i][j];
		end
	end
endfunction : AddRoundKey

function void AesCore :: SubBytes(word8 box[256], ref word8 a[4][`MAXBC]);
	//Every byte from current State is replaced with the value from Sbox 
	for (int i = 0; i < 4; i++) begin
		for (int j = 0; j < BC; j++) begin
			a[i][j] = box [a[i][j]];
		end
	end
	
endfunction : SubBytes

function void AesCore :: ShiftRows( word8 d, ref word8 a[4][`MAXBC]);
	// d is encryption
	word8 tmp[`MAXBC];
	int i, j;
	
	if (d == 0) begin

		for ( i = 1; i < 4; i++) begin
		
			for ( j = 0; j < BC; j++) begin
				tmp [j] = a[i][(j + computed_val.shifts[BC - 4][i]) % BC ];
			end	
			for ( j = 0; j < BC; j++) begin
				a[i][j] = tmp[j];
			end		
			
		end	
	end
	else begin
		for ( i = 1; i < 4; i++) begin
			for ( j = 0; j < BC; j++) begin
				tmp [j] = a[i][(BC + j - computed_val.shifts[BC - 4][i]) % BC ];
			end	
			for ( j = 0; j < BC; j++) begin
				a[i][j] = tmp[j];
			end		
		end
	end
endfunction : ShiftRows

function void AesCore :: MixColumn(ref word8 a[4][`MAXBC]);
	// The byte of every column are mixed in a linear way
	// Equation is
	// 2 3 1 1 * a0
	// 1 2 3 1	 a1
	// 1 1 2 3   a2
	// 3 1 1 2   a3
	word8 res [4][`MAXBC];
	
	int i, j;
	
	for(j = 0; j < BC; j++) begin
		for (i = 0; i < 4; i++)	begin
			res[i][j] = mul(2, a[i][j])
				^ mul(3, a[(i+1) % 4][j])
				^ a[(i + 2) % 4][j]
				^ a[(i + 3) % 4][j];
		end
	end

	for(i = 0; i < 4; i++) begin
		for( j = 0; j < 4; j++) begin
			a[i][j] = res[i][j];
		end
	end
	
endfunction : MixColumn

function void AesCore :: InvMixColumn(ref word8 a[4][`MAXBC]);
	// Decryption MixColumn
	// Equation is
	// 0x0e 0x0b 0x0d 0x09 * a0
	// 0x09 0x0e 0x0b 0x0d	 a1
	// 0x0d 0x09 0x0e 0x0b   a2
	// 0x0b 0x0d 0x09 0x0e   a3
	word8 res [4][`MAXBC];
	int i, j;
	
	for(j = 0; j < BC; j++) begin
		for (i = 0; i < 4; i++)	begin
			res[i][j] = mul(8'h0E, a[i][j])
				^ mul(8'h0B, a[(i+1) % 4][j])
				^ mul(8'h0D, a[(i+2) % 4][j])
				^ mul(8'h09, a[(i+3) % 4][j]);
		end
	end

	for(i = 0; i < 4; i++) begin
		for( j = 0; j < 4; j++) begin
			a[i][j] = res[i][j];
		end
	end
	
endfunction : InvMixColumn

function int AesCore :: KeyExpansion(word8 k[4][`MAXBC], ref word8 W[`MAXROUNDS + 1][4][`MAXBC]);
	int i, j, t, RCpointer = 1;
	word8 tk[4][`MAXKC];
	
	for (j = 0; j < KC; j++) begin
		for(i = 0; i < 4; i++) begin
			tk[i][j] = k[i][j];
		end	
	end
	
	t = 0;
	// prepare values into round key array
	
	for (j = 0; (j < KC) && (t < (ROUNDS + 1)*BC); j++, t++) begin
		for (i = 0; i < 4; i++) begin 
			W[t/BC][i][t % BC] = tk[i][j];
		end	
	end
	$display("t = %0d", t);	
	while (t < (ROUNDS + 1) * BC) begin
	
		//function g non liniar 4 bytes input 
		for (i = 0; i < 4; i++) begin
			tk[i][0] = tk[i][0] ^ computed_val.S[tk[(i+1) % 4][KC -1]];
		end
		
		tk[0][0] = tk[0][0] ^ computed_val.RC[RCpointer++];
		//
		
		if (KC <= 6) begin
			for( j = 1; j < KC; j++) begin
				for (i = 0; i < 4; i++) begin
					tk[i][j] = tk[i][j] ^ tk[i][j-1];
				end
			end
		end
		
		else begin
			for (j = 1; j < 4; j++) begin
				for (i = 0; i < 4; i++) begin
					tk[i][j] = tk[i][j] ^ tk[i][j-1];
				end
			end
			for (i = 0; i < 4; i++) begin
				tk[i][4] = tk[i][4] ^ computed_val.S[tk[i][3]];
			end
			for (j = 5; j < KC; j++) begin
				tk[i][j] = tk[i][j] ^ tk[i][j-1];
			end			
		end	
		
		for (j = 0; (j < KC) && (t < (ROUNDS + 1)*BC); j++, t++) begin
			for (i = 0; i < 4; i++) begin
				W[t/BC][i][t%BC] = tk[i][j];
			end
		end
			
	end	
	return 0;
endfunction : KeyExpansion

function int AesCore :: Encrypt ( ref word8 a[4][`MAXBC],ref  word8 rk[`MAXROUNDS + 1][4][`MAXBC]);
 	int r;
	AddRoundKey(rk[0], a);
	
	for(r = 1; r < ROUNDS; r++) begin
		SubBytes(computed_val.S, a);
		ShiftRows(0, a);
		MixColumn(a);
		AddRoundKey(rk[r], a);
	end 

	SubBytes(computed_val.S, a);
 	ShiftRows(0, a);
	AddRoundKey(rk[ROUNDS], a); 
	
	return 0;
endfunction : Encrypt

function int AesCore :: Decrypt ( ref word8 a[4][`MAXBC],ref  word8 rk[`MAXROUNDS + 1][4][`MAXBC]);
	int r;
	// for decryption methods, apply the operation in oposite order 
	AddRoundKey(rk[ROUNDS], a);
	SubBytes(computed_val.Si, a);
	ShiftRows(1,a);
	 
	for (r = ROUNDS -1; r > 0; r--) begin
		AddRoundKey(rk[r], a);
		InvMixColumn(a);
		SubBytes(computed_val.Si, a);
		ShiftRows(1, a);
	end
	
	AddRoundKey(rk[0], a);
endfunction : Decrypt

task AesCore :: run();
	int i, j;
	
	word8 a[4][`MAXBC], rk[`MAXROUNDS + 1][4][`MAXBC], sk[4][`MAXKC];
	
	BC = 4;
	KC = 4;
	ROUNDS = computed_val.numrounds[KC-4][BC-4];
	for ( i = 0; i < BC; i++) begin
		for (j = 0; j < BC; j++) begin
			a[i][j] = i;
		end		
	end
	
	for (j = 0; j < KC; j++) begin
		for ( i = 0; i < 4; i++) begin
			sk[i][j] = 0;
		end		
	end
	
	$display("\nPlainText ");
	for (j = 0; j < BC; j++) begin
		for ( i = 0; i < BC; i++) begin
			$write("%0h", a[i][j]);
		end
	end
	
	KeyExpansion(sk, rk);
	MixColumn(a);
	
	// Encrypt(a, rk);
	$display("\nCipher ");
	for (j = 0; j < BC; j++) begin
		for ( i = 0; i < BC; i++) begin
			$write("%0h", a[i][j]);
		end
	end
	/*
	Encrypt(a, rk);
	
	$display("\nCipher ");
	for (j = 0; j < BC; j++) begin
		for ( i = 0; i < BC; i++) begin
			$write("%0h", a[i][j]);
		end
	end
	Decrypt(a, rk);
	Decrypt(a, rk);
	
	$display("\nCipher Decrypt");
	for (j = 0; j < BC; j++) begin
		for ( i = 0; i < BC; i++) begin
			$write("%0h", a[i][j]);
		end
	end */
	#10;
endtask : run