@main
enum Perf 
{
    static 
    func main() throws 
    {
        let test:String = 
        """
        benchmarks 102226 18460.447618:     911806 cycles: 
        55c6e55a2f5a $sSS17UnicodeScalarViewVSlsSly7ElementQz5IndexQzcirTW+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV4next33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LL7ElementQzSgyFSS17UnicodeScalarViewV_Tg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON21_GrammarTerminalClassPAAE5parsey12ConstructionQzAA12ParsingInputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__0C0RtzlFZA2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAJV_G_SS17UnicodeScalarViewVTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSONAAO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_x_GAA07ParsingB0A2aIP5parsey12ConstructionQzAA0K5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAQV_SS17UnicodeScalarViewVTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAOV_GTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SS5IndexV_GytTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAOV_GTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV5parse2as12ConstructionQyd__Sgqd__Sgm_tAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAQV_GTg5+0x13a (inlined)
        55c6e55a2f5a $s4JSON12ParsingInputV5parse2as2inyqd__m_ytmtAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzyt12ConstructionRtd__lFSS17UnicodeScalarViewV_A2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSANV_GTg5Tf4ddn_n+0x13a (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a4937 $s4JSON12ParsingInputV5parse2as2inyqd__m_ytmtAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzyt12ConstructionRtd__lFSS17UnicodeScalarViewV_A2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSANV_GTg5+0x247 (inlined)
        55c6e55a4937 $s4JSON7GrammarO3PadO5parsey12ConstructionQzAA12ParsingInputVyqd__GzKSlRd__5IndexQyd__8LocationRt_7ElementQyd__8TerminalRt_lFZAC8EncodingOAAs7UnicodeO6ScalarVRs_rlE5CommaOy_SSALVAY_G_A2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A0__GSS0mN4ViewVTg5+0x247 (inlined)
        55c6e55a4937 $s4JSON7GrammarO3PadOy_xq_GAA11ParsingRuleA2aGP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWAC8EncodingOAAs7UnicodeO6ScalarVRs_rlE5CommaOy_SSAOVA0__G_A2AO0E0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A3__GSS0nO4ViewVTg5+0x247 (inlined)
        55c6e55a4937 $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_5ValueOy_A7__GTg5+0x247 (inlined)
        55c6e55a4937 $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_5ValueOy_A7__GTG5+0x247 (inlined)
        55c6e55a4937 $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AJ8EncodingOAAs0N0O0O0VRs_rlE5CommaOy_SS5IndexVAR_GA2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_AV_GG_AZ5ValueOy_AV_Gtyt_AXtTg5+0x247 (inlined)
        55c6e55a4937 $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AW8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA3__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A6__GGA10_5ValueOy_A6__GTg5+0x247 (inlined)
        55c6e55a4937 $s4JSONAAO4RuleO5Array33_CEFB79D06B863FC55EDE85E244D7901ELLO5parseySayABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAMV_SS0oP4ViewVTg5Tf4nd_n+0x247 (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a4a11 $s4JSONAAO4RuleO5Array33_CEFB79D06B863FC55EDE85E244D7901ELLO5parseySayABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAMV_SS0oP4ViewVTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSONAAO4RuleO5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_x_GAA07ParsingB0A2aIP5parsey12ConstructionQzAA0K5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAQV_SS17UnicodeScalarViewVTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAOV_GTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAOV_GTG5+0x71 (inlined)
        55c6e55a4a11 $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SS5IndexV_GSayAIGTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAOV_GTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__Sgqd__Sgm_tAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O5Array33_CEFB79D06B863FC55EDE85E244D7901ELLOy_SSAQV_GTg5+0x71 (inlined)
        55c6e55a4a11 $s4JSONAAO4RuleO5ValueO5parseyAbA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAKV_SS0hI4ViewVTg5Tf4nd_n+0x71 (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a41a7 $s4JSONAAO4RuleO5ValueO5parseyAbA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAKV_SS0hI4ViewVTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSONAAO4RuleO5ValueOy_x_GAA07ParsingB0A2aHP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAPV_SS17UnicodeScalarViewVTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTG5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO5ValueOy_SS5IndexV_GAITg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSONAAO4RuleO6ObjectO4ItemO5parseySS3key_AB5valuetAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAOV_SS0kL4ViewVTg5Tf4nd_n+0x87 (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO4ItemO5parseySS3key_AB5valuetAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAOV_SS0kL4ViewVTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO4ItemOy_x__GAA07ParsingB0A2aJP5parsey12ConstructionQzAA0E5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSARV_SS17UnicodeScalarViewVTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_6ObjectO4ItemOy_A7___GTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_6ObjectO4ItemOy_A7___GTG5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AJ8EncodingOAAs0N0O0O0VRs_rlE5CommaOy_SS5IndexVAR_GA2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_AV_GG_AZ6ObjectO4ItemOy_AV__Gtyt_SS3key_AX5valuettTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AW8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA3__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A6__GGA10_6ObjectO4ItemOy_A6___GTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO5parseySDySSABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSALV_SS0hI4ViewVTg5Tf4nd_n+0x3fa (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a4a40 $s4JSONAAO4RuleO6ObjectO5parseySDySSABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSALV_SS0hI4ViewVTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSONAAO4RuleO6ObjectOy_x_GAA07ParsingB0A2aHP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAPV_SS17UnicodeScalarViewVTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTG5+0xa0 (inlined)
        55c6e55a4a40 $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO6ObjectOy_SS5IndexV_GSDySSAIGTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__Sgqd__Sgm_tAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAQV_GTg5+0xa0 (inlined)
        55c6e55a4a40 $s4JSONAAO4RuleO5ValueO5parseyAbA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAKV_SS0hI4ViewVTg5Tf4nd_n+0xa0 (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a41a7 $s4JSONAAO4RuleO5ValueO5parseyAbA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAKV_SS0hI4ViewVTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSONAAO4RuleO5ValueOy_x_GAA07ParsingB0A2aHP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAPV_SS17UnicodeScalarViewVTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTG5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO5ValueOy_SS5IndexV_GAITg5+0x87 (inlined)
        55c6e55a41a7 $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTg5+0x87 (inlined)
        55c6e55a41a7 $s4JSONAAO4RuleO6ObjectO4ItemO5parseySS3key_AB5valuetAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAOV_SS0kL4ViewVTg5Tf4nd_n+0x87 (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO4ItemO5parseySS3key_AB5valuetAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAOV_SS0kL4ViewVTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO4ItemOy_x__GAA07ParsingB0A2aJP5parsey12ConstructionQzAA0E5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSARV_SS17UnicodeScalarViewVTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_6ObjectO4ItemOy_A7___GTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFAG_AHtACyxGzKXEfU_SS17UnicodeScalarViewV_AA7GrammarO3PadOy_AX8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA4__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A7__GGA11_6ObjectO4ItemOy_A7___GTG5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AJ8EncodingOAAs0N0O0O0VRs_rlE5CommaOy_SS5IndexVAR_GA2AO4RuleO10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_AV_GG_AZ6ObjectO4ItemOy_AV__Gtyt_SS3key_AX5valuettTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSON12ParsingInputV5parse2as12ConstructionQyd___AFQyd_0_tqd___qd_0_tm_tKAA0B4RuleRd__AaIRd_0_8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzANQyd_0_AORSAJQyd_0_AKRSr0_lFSS17UnicodeScalarViewV_AA7GrammarO3PadOy_AW8EncodingOAAs0L0O0M0VRs_rlE5CommaOy_SSAPVA3__GA2AO0G0O10Whitespace33_CEFB79D06B863FC55EDE85E244D7901ELLOy_A6__GGA10_6ObjectO4ItemOy_A6___GTg5+0x3fa (inlined)
        55c6e55a45ea $s4JSONAAO4RuleO6ObjectO5parseySDySSABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSALV_SS0hI4ViewVTg5Tf4nd_n+0x3fa (/home/klossy/dev/ss-json/.build/x86_64-unknown-linux-gnu/release/benchmarks)
        55c6e55a5def $s4JSONAAO4RuleO6ObjectO5parseySDySSABGAA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSALV_SS0hI4ViewVTg5+0x12af (inlined)
        55c6e55a5def $s4JSONAAO4RuleO6ObjectOy_x_GAA07ParsingB0A2aHP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAPV_SS17UnicodeScalarViewVTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTG5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO6ObjectOy_SS5IndexV_GSDySSAIGTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAOV_GTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__Sgqd__Sgm_tAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFSS17UnicodeScalarViewV_A2AO0G0O6ObjectOy_SSAQV_GTg5+0x12af (inlined)
        55c6e55a5def $s4JSONAAO4RuleO5ValueO5parseyAbA12ParsingInputVyqd__GzK5IndexQyd__RszSlRd__s7UnicodeO6ScalarV7ElementRtd__lFZSSAKV_SS0hI4ViewVTg5+0x12af (inlined)
        55c6e55a5def $s4JSONAAO4RuleO5ValueOy_x_GAA07ParsingB0A2aHP5parsey12ConstructionQzAA0D5InputVyqd__GzKSlRd__5IndexQyd__8LocationRtz7ElementQyd__8TerminalRtzlFZTWSSAPV_SS17UnicodeScalarViewVTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTg5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5parse2as12ConstructionQyd__qd__m_tKAA0B4RuleRd__8TerminalQyd__7ElementRtz8LocationQyd__5IndexRtzlFAgCyxGzKXEfU_SS17UnicodeScalarViewV_A2AO0G0O5ValueOy_SSAOV_GTG5+0x12af (inlined)
        55c6e55a5def $s4JSON12ParsingInputV5group33_1B94CF74D2CAE9ACCA10B6F46CA4FB04LLyqd_0_qd__m_qd_0_ACyxGzKXEtKr0_lFSS17UnicodeScalarViewV_A2AO4RuleO5ValueOy_SS5IndexV_GAITg5+0x12af (inlined)
        """
        print(try Grammar.parse(test.unicodeScalars, as: Rule<String.Index>.Sample.self))
    }
    
    struct Process:Identifiable
    {
        let id:UInt 
        let command:String 
    }
    enum Convention 
    {
        case c 
        case swift 
    }
    enum Module 
    {
        case kernel 
        case inlined 
        case binary([String])
    }
    struct Sample 
    {
        struct Frame 
        {
            let symbol:(description:String, convention:Convention)?
            let module:Module?
        }
        
        let period:Int
        let trace:[Frame]
    }
    enum Rule<Location>
    {
        typealias Codepoint = Grammar.Encoding<Location, Unicode.Scalar>
        typealias Digit<T>  = Grammar.Digit<Location, Unicode.Scalar, T> where T:BinaryInteger
    }
}
extension Perf.Rule 
{
    enum Keyword 
    {
        enum Cycles:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["c", "y", "c", "l", "e", "s"] }
        }
        enum Inlined:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["i", "n", "l", "i", "n", "e", "d"] }
        }
        enum KernelKallsyms:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["k", "e", "r", "n", "e", "l", ".", "a", "l", "l", "s", "y", "m", "s"] }
        }
        enum Unknown:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["u", "n", "k", "n", "o", "w", "n"] }
        }
    }
    enum Whitespace:ParsingRule 
    {
        enum Element:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Void 
            static 
            func parse(terminal:Unicode.Scalar) -> Void? 
            {
                switch terminal 
                {
                case " ", "\t": return ()
                default:        return nil
                }
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Void
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Element.self)
            input.parse(as: Element.self, in: Void.self)
        }
    }
    enum AbsolutePath:ParsingRule
    {
        enum Component:ParsingRule 
        {
            private 
            enum Element:ParsingRule 
            {
                private 
                enum Escaped:Grammar.TerminalClass 
                {
                    typealias Terminal      = Unicode.Scalar
                    typealias Construction  = Unicode.Scalar 
                    static 
                    func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                    {
                        terminal
                    }
                }
                private 
                enum Unescaped:Grammar.TerminalClass
                {
                    typealias Terminal      = Unicode.Scalar
                    typealias Construction  = Unicode.Scalar 
                    static 
                    func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                    {
                        switch terminal 
                        {
                        case "(", ")", "/", "\\":
                            return nil  
                        default:
                            return terminal
                        }
                    }
                } 
                
                typealias Terminal = Unicode.Scalar
                static 
                func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Character
                    where   Diagnostics:ParsingDiagnostics,
                            Diagnostics.Source.Index == Location,
                            Diagnostics.Source.Element == Terminal
                {
                    if let scalar:Unicode.Scalar = input.parse(as: Unescaped?.self) 
                    {
                        return Character.init(scalar)
                    }
                    let (_, scalar):(Void, Unicode.Scalar) = 
                        try input.parse(as: (Codepoint.Backslash, Escaped).self)
                    return Character.init(scalar)
                }
            }
            
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                try input.parse(as: Codepoint.Slash.self)
                return input.parse(as: Element.self, in: String.self)
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> [String]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Grammar.Reduce<Component, [String]>.self).compactMap { $0 }
        }
    }
    enum Module:ParsingRule
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Perf.Module
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let module:Perf.Module 
            try input.parse(as: Codepoint.ParenthesisLeft.self)
            if let _:Void = input.parse(as: Codepoint.BracketLeft?.self)
            {
                try input.parse(as: Keyword.KernelKallsyms.self)
                try input.parse(as: Codepoint.BracketRight.self)
                module = .kernel 
            }
            else if let _:Void = input.parse(as: Keyword.Inlined?.self)
            {
                module = .inlined 
            }
            else 
            {
                module = .binary(try input.parse(as: AbsolutePath.self))
            }
            try input.parse(as: Codepoint.ParenthesisRight.self)
            return module 
        }
    }
    enum Identifier:ParsingRule 
    {
        enum Head:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Character 
            static 
            func parse(terminal:Unicode.Scalar) -> Character? 
            {
                switch terminal 
                {
                case    "a" ... "z", 
                        "A" ... "Z",
                        "_", 
                        
                        "\u{00A8}", "\u{00AA}", "\u{00AD}", "\u{00AF}", 
                        "\u{00B2}" ... "\u{00B5}", "\u{00B7}" ... "\u{00BA}",
                        
                        "\u{00BC}" ... "\u{00BE}", "\u{00C0}" ... "\u{00D6}", 
                        "\u{00D8}" ... "\u{00F6}", "\u{00F8}" ... "\u{00FF}",
                        
                        "\u{0100}" ... "\u{02FF}", "\u{0370}" ... "\u{167F}", "\u{1681}" ... "\u{180D}", "\u{180F}" ... "\u{1DBF}", 
                        
                        "\u{1E00}" ... "\u{1FFF}", 
                        
                        "\u{200B}" ... "\u{200D}", "\u{202A}" ... "\u{202E}", "\u{203F}" ... "\u{2040}", "\u{2054}", "\u{2060}" ... "\u{206F}",
                        
                        "\u{2070}" ... "\u{20CF}", "\u{2100}" ... "\u{218F}", "\u{2460}" ... "\u{24FF}", "\u{2776}" ... "\u{2793}",
                        
                        "\u{2C00}" ... "\u{2DFF}", "\u{2E80}" ... "\u{2FFF}",
                        
                        "\u{3004}" ... "\u{3007}", "\u{3021}" ... "\u{302F}", "\u{3031}" ... "\u{303F}", "\u{3040}" ... "\u{D7FF}",
                        
                        "\u{F900}" ... "\u{FD3D}", "\u{FD40}" ... "\u{FDCF}", "\u{FDF0}" ... "\u{FE1F}", "\u{FE30}" ... "\u{FE44}", 
                        
                        "\u{FE47}" ... "\u{FFFD}", 
                        
                        "\u{10000}" ... "\u{1FFFD}", "\u{20000}" ... "\u{2FFFD}", "\u{30000}" ... "\u{3FFFD}", "\u{40000}" ... "\u{4FFFD}", 
                        
                        "\u{50000}" ... "\u{5FFFD}", "\u{60000}" ... "\u{6FFFD}", "\u{70000}" ... "\u{7FFFD}", "\u{80000}" ... "\u{8FFFD}", 
                        
                        "\u{90000}" ... "\u{9FFFD}", "\u{A0000}" ... "\u{AFFFD}", "\u{B0000}" ... "\u{BFFFD}", "\u{C0000}" ... "\u{CFFFD}", 
                        
                        "\u{D0000}" ... "\u{DFFFD}", "\u{E0000}" ... "\u{EFFFD}"
                        :
                    return .init(terminal)
                default:
                    return nil
                }
            }
        }
        enum Next:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Character 
            static 
            func parse(terminal:Unicode.Scalar) -> Character? 
            {
                if let character:Character = Head.parse(terminal: terminal) 
                {
                    return character
                }
                switch terminal 
                {
                case    "0" ... "9", 
                        "\u{0300}" ... "\u{036F}", 
                        "\u{1DC0}" ... "\u{1DFF}", 
                        "\u{20D0}" ... "\u{20FF}", 
                        "\u{FE20}" ... "\u{FE2F}":
                    return .init(terminal)
                default:
                    return nil
                }
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            var string:String = .init(try input.parse(as: Head.self))
            while let next:Character = input.parse(as: Next?.self)
            {
                string.append(next)
            }
            return string 
        }
    }
    enum Symbol:ParsingRule 
    {
        enum Offset:ParsingRule 
        {
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> UInt
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                try input.parse(as: Codepoint.Plus.self)
                try input.parse(as: Codepoint.Zero.self)
                try input.parse(as: Codepoint.X.Lowercase.self)
                return try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt>.Hex.Anycase>.self)
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) 
            throws -> (description:String, convention:Perf.Convention)?
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let convention:Perf.Convention, 
                description:String 
            if let _:Void = input.parse(as: Codepoint.Dollar?.self)
            {
                // swift symbol 
                convention  = .swift
                description = Demangle["$\(try input.parse(as: Identifier.self))"]
                let _:UInt? = input.parse(as: Offset?.self)
            }
            else if let _:(Void, Void, Void) = 
                try? input.parse(as: (Codepoint.BracketLeft, Keyword.Unknown, Codepoint.BracketRight).self)
            {
                return nil
            }
            else 
            {
                convention  = .c
                description = try input.parse(as: Identifier.self)
                let _:UInt? = input.parse(as: Offset?.self)
            }
            return (description, convention)
        }
    }
    enum Sample:ParsingRule 
    {
        enum Frame:ParsingRule 
        {
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Perf.Sample.Frame
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                let _:UInt = 
                    try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt>.Hex.Anycase>.self)
                try input.parse(as: Whitespace.self)
                let symbol:(description:String, convention:Perf.Convention)? = 
                    try input.parse(as: Symbol.self)
                try input.parse(as: Whitespace.self)
                let module:Perf.Module? = 
                    try input.parse(as: Module.self)
                return .init(symbol: symbol, module: module)
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> (process:Perf.Process, sample:Perf.Sample)
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let command:String = 
                try input.parse(as: Identifier.self)
            let (_, process):(Void, UInt) = 
                try input.parse(as: (Whitespace,    Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            
            let _:(Void, UInt)? = try? input.parse(as:    (Whitespace,    Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            let _:(Void, UInt)? = try? input.parse(as: (Codepoint.Period, Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            
            try input.parse(as: Grammar.Pad<Codepoint.Colon, Whitespace.Element>.self)
            let period:Int = 
                try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<Int>.Decimal>.self)
            try input.parse(as: (Whitespace, Keyword.Cycles).self)
            try input.parse(as: Grammar.Pad<Codepoint.Colon, Whitespace.Element>.self)
            
            var trace:[Perf.Sample.Frame] = []
            while let _:Void = input.parse(as: Codepoint.Newline?.self)
            {
                input.parse(as: Whitespace.Element.self, in: Void.self)
                guard let frame:Perf.Sample.Frame = input.parse(as: Frame?.self)
                else 
                {
                    break 
                }
                trace.append(frame)
            }
            return (.init(id: process, command: command), .init(period: period, trace: trace))
        }
    }
}
