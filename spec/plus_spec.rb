require 'plus'
RSpec.describe Plus do
	
	context "This module provides some useful \"Sugar\" 
with :+ to help process data" do 
			let(:work) { 
					work = Class.new(PlusObj) do
            def initialize
              super
            end
						def fib arg
							  arg << 'fib' 
						end
						def fab arg
							 arg << 'fab' 
						end
					end	
			}
		it "Entry point to the sugar is 'op'" do
			expect(work.new).to respond_to(:op)				
		end
		it "can compose methods with +" do
			work.class_eval do
				def fibfab 
					(op(:fib) + op(:fab)).call("")
				end
			end
			sut = work.new
			expect(sut.fibfab).to eq('fibfab') 
		end

		it "can compose 'datasource' and method, method args come for 'datasource'" do
			work.class_eval do
				def change_key h 
					h[:zip] = :zap
					h
				end	

				def datasource 
					h = {zip: :fib,zop: :fob} 
          ( data([h]) + op(:change_key) ).take(1).force
				end
			end
			sut = work.new
			result = sut.datasource
			expect(result.first[:zip]).to  eq :zap
		end

		it "'datasource' can be anything with an :each" do
			
			work.class_eval do
				def csv_source  
						require 'csv'
						CSV.new(File.open('lib/data/zoo-project.csv','r'),{})
            # Name, Species, Type, Climate, Gender, Age
            # Jimi, Penguin, Carnivore, Polar, M, 10
            # Steve, Penguin, Carnivore, Polar, M, 2
            # Janis, Penguin, Carnivore, Polar, F, 5
            # ...
				end	
				def find_jimi row
          return nil unless row
					if row[0] == 'Jimi'
						row
					else
						nil
					end
				end
				def find_boys row
          return nil unless row
					if row && row[4] =~ /M/ 
						row
					else
						nil
					end

				end
				def who_like_meat row
          return nil unless row
					if row && row[2] =~ /Carnivore/
						row
					else
						nil
					end

				end	
				def finder 
					jimi_finder =  data(csv_source) + op(:find_jimi)
          jimi_finder.collect(&_id).force.compact
				end
				def find_boys_who_like_meat
					src =  data(csv_source) + op(:find_boys) + op(:who_like_meat)
          src.collect(&_id).force.compact
				end

			end
			sut = work.new
      result = sut.finder
      #first result, 
      expect(result.length).to eq 1
			expect(result.first[0]).to  eq 'Jimi' 
    
			meat_boys = sut.find_boys_who_like_meat
      expect(meat_boys.length).to eq 8
			meat_boys.each do |answer|
				expect(answer[2]).to match(/Carnivore/)  
				expect(answer[4]).to match(/M/)  
			end
		end

		
	end
	

end
