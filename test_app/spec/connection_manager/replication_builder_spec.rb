require 'spec_helper'

describe ConnectionManager::ReplicationBuilder do
  
  context '#database_name' do
    it "should return the name of the database the model is using" do
      Fruit.database_name.should eql('test_app')
    end
  end

  context '#other_association_options' do
    
      it "should add :class_name options set to the replication subclass if :class_name is blank" do
        options = Fruit.replication_association_options(:has_one, :plant, 'Slave')
        options[:class_name].should eql("Plant::Slave")
      end
      
      it "should append :class_name with the replication subclass if :class_name is not bank" do
        options = Fruit.replication_association_options(:has_one, :plant, 'Slave', :class_name => 'Plant')
        options[:class_name].should eql("Plant::Slave")
      end
    
    context "has_one or has_many" do
    it "should add the :foreign_key if the :foreign_key options is not present" do
      options = Fruit.replication_association_options(:has_one, :plant, 'Slave')
      options[:foreign_key].should eql('fruit_id')
      options = Fruit.replication_association_options(:has_many, :plant, 'Slave')
      options[:foreign_key].should eql('fruit_id')
    end
    end
  end
end

