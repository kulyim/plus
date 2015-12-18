require 'plus/csvdata'
RSpec.describe 'CSVData' do
    context "create one with a path to a csv file"
            # our data 
            # Name, Species, Type, Climate, Gender, Age
            # Jimi, Penguin, Carnivore, Polar, M, 10
            # Steve, Penguin, Carnivore, Polar, M, 2
            # Janis, Penguin, Carnivore, Polar, F, 5
    let(:csv){
      CSVData.new 'lib/data/zoo-project.csv'
    }
    it "Should use first row has has headers" do
      expect(csv.header).to eq ["Name", "Species", "Type", "Climate", "Gender", "Age"]
    end

    it "Creates hashes for rows, using the header and column values" do
      expect(csv.process().take(1).first).to be_a_kind_of(Hash)
    end

    it "Our data says first hash should have Name => 'Jimi'" do
      result = csv.process().take(1).first
      expect(result.keys).to include('Name') 
      expect(result.values).to include('Jimi') 
      expect(result['Name']).to eq('Jimi')
    end

    it "Can send simple messages to keys or values" do
      result = csv.process(:keys_reverse,:keys_downcase,:values_downcase,:values_reverse).take(1).first
      expect(result.keys).to include('eman') 
      expect(result.values).to include('ralop') 
      expect(result['eman']).to eq('imij')
    end

    it "Can add a lambda to handle the pairs differently" do
      underscorer = ->(pair){["_" + pair[0] + "_", pair[1] ]}
      result = csv.process(:keys_reverse, underscorer).take(1).first
      expect(result.keys).to include('_emaN_') 

    end

    it "Can do work on the resulting hash output" do
      result = csv.process(:keys_strip,:values_strip, :keys_downcase, :keys_to_sym)do |hash|
        hash[:newkey] = 'larry'
        hash
      end.take(1).first
      expect(result.keys).to all( be_kind_of(Symbol) )
      expect(result[:newkey]).to eq('larry')
    end

    it "Can 'plus' the work and do more work on the results of the results of the results ..." do
      i_am_bill = ->(h){h[:newkey] = 'Bill';h}
     
      theprocess = csv.process(:keys_strip,:values_strip, :keys_downcase, :keys_to_sym)do |hash|
        hash[:newkey] = 'larry'
        hash
      end  

      final = theprocess + i_am_bill
      
      result = final.take(1).first
      expect(result[:newkey]).to eq('Bill')
    end

end
