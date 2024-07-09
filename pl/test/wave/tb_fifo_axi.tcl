set nfacts [gtkwave::getNumFacs]
puts "$nfacts"

# Function to add a signal and handle errors if it doesn't exist
proc addSignal {signal} {
    set result [catch {gtkwave::addSignalsFromList "$signal"} error_message]
    if {$result != 0} {
        puts "Error adding signal $signal: $error_message"
    }
}

# List of signals to add
set signals {
    tb_fifo_axi.clk -
    tb_fifo_axi.reset -

    tb_fifo_axi.wr_en -
    tb_fifo_axi.rd_en -

    tb_fifo_axi.TB_wr_data_0 -
    tb_fifo_axi.TB_wr_data_1 -
    tb_fifo_axi.TB_wr_data_2 -
    tb_fifo_axi.TB_wr_data_3 -
    tb_fifo_axi.TB_wr_data_4 -
    tb_fifo_axi.TB_wr_data_5 -
    tb_fifo_axi.TB_wr_data_6 -
    tb_fifo_axi.TB_wr_data_7 -
    tb_fifo_axi.TB_wr_data_8 -
    tb_fifo_axi.TB_wr_data_9 -
    tb_fifo_axi.TB_wr_data_246 -
    tb_fifo_axi.TB_wr_data_247 -
    tb_fifo_axi.TB_wr_data_248 -
    tb_fifo_axi.TB_wr_data_249 -
    tb_fifo_axi.TB_wr_data_250 -
    tb_fifo_axi.TB_wr_data_251 -
    tb_fifo_axi.TB_wr_data_252 -
    tb_fifo_axi.TB_wr_data_253 -
    tb_fifo_axi.TB_wr_data_254 -
    tb_fifo_axi.TB_wr_data_255 -

    tb_fifo_axi.TB_rd_data_0 -
    tb_fifo_axi.TB_rd_data_1 -
    tb_fifo_axi.TB_rd_data_2 -
    tb_fifo_axi.TB_rd_data_3 -
    tb_fifo_axi.TB_rd_data_4 -
    tb_fifo_axi.TB_rd_data_5 -
    tb_fifo_axi.TB_rd_data_6 -
    tb_fifo_axi.TB_rd_data_7 -
    tb_fifo_axi.TB_rd_data_8 -
    tb_fifo_axi.TB_rd_data_9 -
    tb_fifo_axi.TB_rd_data_246 -
    tb_fifo_axi.TB_rd_data_247 -
    tb_fifo_axi.TB_rd_data_248 -
    tb_fifo_axi.TB_rd_data_249 -
    tb_fifo_axi.TB_rd_data_250 -
    tb_fifo_axi.TB_rd_data_251 -
    tb_fifo_axi.TB_rd_data_252 -
    tb_fifo_axi.TB_rd_data_253 -
    tb_fifo_axi.TB_rd_data_254 -
    tb_fifo_axi.TB_rd_data_255 -

}

# Iterate through the list of signals and add them
foreach signal $signals {
    addSignal $signal
}

# zoom full
gtkwave::/Time/Zoom/Zoom_Full