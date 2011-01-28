require 'rspec'
require 'janogb'

describe "CPU operations" do
  include JanoGB
  
  it "should have a NOP operation with opcode 0x00 that does nothing" do
    cpu = CPU.new
    
    cpu.load_with(0x00).run(1)

    [:a, :f, :b, :c, :d, :e, :h, :l, :sp].each do |r|
      cpu.instance_variable_get("@#{r}").should == 0x00
    end
    
    cpu.pc.should == 0x0001
    cpu.clock.should == 1
  end
  
  describe "LD RR,nn operations" do
    it "must be 4" do
      cpu = CPU.new
      
      [:ld_bc_nn, :ld_de_nn, :ld_hl_nn, :ld_sp_nn].each do |m|
        cpu.should respond_to m
      end
    end
  
    it "must load a 16 bit value into a 16 bit register" do
      cpu = CPU.new
    
      cpu.load_with(0x01, 0xAB, 0xCD).run(1)
    
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.bc.should == 0xABCD
      cpu.pc.should == 0x0003
      cpu.clock.should == 3
    end
  end
  
  describe "LD (RR), A operations" do
    it "must be 3" do
      cpu = CPU.new
      
      [:ld_mbc_a, :ld_mde_a, :ld_mhl_a].each do |m|
        cpu.should respond_to m
      end
    end
  
    it "must load the A register into the memory at address pointed by register RR" do
      cpu = CPU.new(a:0xAB, b: 0xCA, c:0xFE)
    
      cpu.load_with(0x02).run(1)
    
      [:f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
    
      cpu.mmu[0xCAFE] = 0xAB
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
  describe "INC RR operations" do
    it "must be 4" do
      cpu = CPU.new
      
      [:inc_bc, :inc_de, :inc_hl, :inc_sp].each do |m|
        cpu.should respond_to m
      end
    end
    
    it "should increment a register" do
      cpu = CPU.new
      
      cpu.load_with(0x03).run(1)
      
      [:a, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.bc.should == 0x0001
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
    
    it "should let in 0x0000 a register with 0xFFFF" do
      cpu = CPU.new(b:0xFF, c:0xFF)
      
      cpu.load_with(0x03).run(1)
      
      [:a, :b, :c, :f, :d, :e, :h, :l, :sp].each do |r|
        cpu.instance_variable_get("@#{r}").should == 0x00
      end
      
      cpu.pc.should == 0x0001
      cpu.clock.should == 2
    end
  end
  
end