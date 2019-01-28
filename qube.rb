class Qube

  def self.add_distributor_name
    @data = Hash.new {|h, k| h[k] = []}
    add_distributor
  end

  def self.add_distributor
    puts "Enter 0 if you want exit program. \nEnter 1 if you want add distributor. \nEnter 2 if you want add distribution permission on a particular distributor"
    status = gets.chomp.to_i
    case status
      when 1
        puts 'Please enter name of the distributor.'
        distributor_name = gets.chomp.to_s.downcase
        if @data.key?(distributor_name)
          puts "#{distributor_name} already present"
        else
          puts "#{distributor_name} added successfully"
          @data[distributor_name] = {"include" => [], "exclude" => []}
        end
        add_distributor
      when 2
        add_area('');
      when 0
      else
        puts 'please enter a valid input'
        add_distributor
    end
  end

  def self.add_area(current_distributor)
    if @data.length === 0
      puts 'Please add at least one distributor'
      add_distributor
    else
      if current_distributor && @data.key?(current_distributor) && @data.length > 1
        puts 'If you want change distributor please enter 1 else enter'
        if gets.chomp.to_i === 1
          add_area('')
        else
          distributor_name = current_distributor
        end
      elsif @data.length === 1
        distributor_name = @data.keys[0]
      else
        puts 'Please select distributor for adding permission'
        puts 'Given below available distributes list'
        @data.each_pair {|key, value| puts "#{key}"}
        distributor_name = gets.chomp.to_s.downcase
      end
      if @data.key?(distributor_name)
        puts "select 1 for include permission,select 2 for exclude permission. If you don't want add permission please enter 0"
        permission = gets.chomp.to_i
        puts 'Please make sure if you want include or exclude entire country, Please enter country name ex:india or India'
        puts "If you want include or exclude Province, please enter Province Name and Country Name with comma separation\n ex:Jammu and Kashmir,India"
        puts "If you want include or exclude City Please enter City Name,Province Name,Country Name with comma separation\n ex:Punch,Jammu and Kashmir,India"
        if permission == 1
          add_areas('include', distributor_name, 'exclude')
        elsif permission == 2
          add_areas('exclude', distributor_name, 'include')
        else
          puts "Want to add more areas for distribution right please select 1"
          puts "Want to check particular distributor have present permission on some area please select 2 "
          puts "Want to selling distribution rights please select 3"
          puts "Want to exit program please select 0"
          status = gets.chomp.to_i
          if status === 1
            add_area(distributor_name)
          elsif status === 2
            check_right
          elsif status === 3
            parent_add
          elsif status === 0
          else
            puts "you entered wrong value"
            add_area(current_distributor)
          end
        end
      else
        puts "please select valid distributor"
        add_area(distributor_name)
      end
    end
  end

  def self.add_areas(type, distributor_name, opp_type)
    puts "Please enter which area you want to #{type} for #{distributor_name}"
    area = gets.chomp.to_s.downcase
    split_area = area.split(',')
    if @data[distributor_name][opp_type].include?(area) || @data[distributor_name][type].include?(area)
      puts "Please check #{area} that already present in #{opp_type} or #{type}"
      add_area(distributor_name)
    else
      if split_area.length === 2 && @data[distributor_name]["#{type}"].include?(split_area[1])
        puts "Already you have present permission"
      elsif split_area.length == 3 && (@data[distributor_name]["#{type}"].include?(split_area[1]) || @data[distributor_name]["#{type}"].include?("#{split_area[1]},#{split_area[2]}"))
        puts "Already you have present permission"
      else
        if check_data_valid(area)
          if split_area.length > 1 && type == 'exclude' && @data[distributor_name]["include"].length > 0
            if (split_area.length == 2) && (@data[distributor_name]["include"].include?(split_area[1]) || @data[distributor_name]["include"].include?("#{split_area[0]},#{split_area[1]}"))
              @data[distributor_name]["#{type}"].push(area)
            elsif (split_area.length == 3) && (@data[distributor_name]["include"].include?("#{split_area[1]},#{split_area[2]}") || @data[distributor_name]["include"].include?(split_area[2]))
              @data[distributor_name]["#{type}"].push(area)
            else
              puts "You don't have permission for distribution for #{split_area[1]}"
            end
          elsif type == 'include'
            @data[distributor_name]["#{type}"].push(area)
          else
            puts "please first add distribution permission in include section"
          end
          if split_area.length > 0
            @data[distributor_name]["#{type}"].each do |data|
              if (data =~ /^\w+,#{area}/)
                @data[distributor_name]["#{type}"].delete(data)
              end
            end
          end
        else
          puts "Please check #{area} that not available"
        end
      end
    end
    add_area(distributor_name)
  end

  def self.parent_add
    if @data.length > 1
      puts "if you want selling your distribution right to someone please enter yes"
      if gets.chomp.to_s.downcase == 'yes'
        puts "please select seller name\n Given below showing available distributes list"
        @data.each_pair {|key, value| puts "#{key}"}
        seller = gets.chomp.to_s.downcase
        if @data.key?(seller) && (!@data[seller].key?("include") || @data[seller]["include"].length === 0)
          puts "#{seller} don't have any distribution rights "
          parent_add
        elsif !@data.key?(seller)
          puts "#{seller} not present"
          parent_add
        else
          puts "please select buyer name"
          buyer = gets.chomp.to_s.downcase
          if @data.key?(seller) && @data.key?(buyer) && seller != buyer
            puts "select which area distribution you want sell"
            area = gets.chomp.to_s.downcase
            area_list = area.split(',')
            if (area_list.length === 1) && @data[seller]["include"].include?(area)
              @data[buyer]["include"].push(area)
              @data[seller]["include"].delete(area)
              @data[buyer]["exclude"].delete(area)
              @data[seller]["exclude"].delete(area)
              puts "Successfully transfer your #{area} right to #{buyer}"
            elsif area_list.length === 2 && !@data[seller]["exclude"].include?(area) && !@data[seller]["exclude"].include?(area_list[1])
              if @data[seller]["include"].include?(area) || @data[seller]["include"].include?(area_list[1])
                @data[buyer]["include"].push(area)
                @data[seller]["include"].delete(area)
                @data[seller]["exclude"].push(area)
                @data[buyer]["exclude"].delete(area)
                puts "Successfully transfer your #{area} right to #{buyer}"
              else
                puts "you can't the right for selling #{area}"
              end
            elsif (area_list.length === 3) && !@data[seller]["exclude"].include?(area) && !@data[seller]["exclude"].include?("#{area_list[1]},#{area_list[2]}")
              if (@data[seller]["include"].include?(area) || @data[seller]["include"].include?(area_list[2])) || @data[seller]["include"].include?("#{area_list[1]},#{area_list[2]}")
                @data[buyer]["include"].push(area)
                @data[seller]["exclude"].push(area)
                puts "Successfully transfer your #{area} right to #{buyer}"
              else
                puts "you can't the right for selling #{area}"
              end
            else
              puts "you can't the right for selling #{area}"
            end
            parent_add
          else
            puts "Invalid distributor"
            parent_add
          end
        end
      else
        puts "Want to add new distributor please select 1 "
        puts "Want to check distribution rights for particular distributor please select 2 "
        puts "Want to selling distribution right please select 3 "
        puts "Want to exit program select 0"
        status = gets.chomp.to_i
        if status === 1
          add_distributor
        elsif status === 2
          check_right
        elsif status === 0
        elsif status === 3
          parent_add
        else
          puts "you entered wrong data"
          parent_add
        end
      end
    else
      puts "Please add at least one more distributor"
      puts "Want to add new distributor please select 1 "
      puts "Want to check area permission select 2 "
      puts "Want to exit select 0"
      status = gets.chomp.to_i
      if status === 1
        add_distributor
      elsif status === 2
        check_right
      elsif status === 0
      else
        puts "you entered wrong data"
        parent_add
      end
    end
  end

  def self.check_right
    if @data.length === 1
      distributor = @data.keys[0]
    else
      puts "Please select distributor name"
      @data.each_pair {|key, value| puts "#{key}"}
      distributor = gets.chomp.to_s.downcase
    end
    if @data.key?(distributor) && (!@data[distributor].key?("include") || @data[distributor]["include"].length === 0)
      puts "#{distributor} don't have any distribution right "
      check_right
    elsif !@data.key?(distributor)
      puts "#{distributor} not present"
      check_right
    else
      puts "Please enter area which you want check"
      area = gets.chomp.to_s.downcase
      area_list = area.split(',')
      if @data[distributor]["exclude"].include?(area)
        puts "No....."
      elsif @data[distributor]["include"].include?(area)
        puts "yes....."
      else
        if check_data_valid(area) && area_list.length === 2 && !@data[distributor]["exclude"].include?(area_list[1]) && @data[distributor]["include"].include?(area_list[1])
          puts "yes....."
        elsif check_data_valid(area) && area_list.length === 3 && !@data[distributor]["exclude"].include?(area_list[2]) && (@data[distributor]["include"].include?("#{area_list[1]},#{area_list[2]}") || @data[distributor]["include"].include?(area_list[2]))
          puts "yes....."
        else
          puts "no"
        end
      end
    end
    check_right
  end

  def self.check_data_valid(area)
    f = File.open("cites.csv", "r")
    data = area.split(',')
    if data.length === 1
      f.drop(1).each do |line|
        x = line.split(",")
        if x[5].chomp.downcase === data[0].downcase
          return true
          break
        end
      end
      return false
    elsif data.length === 2
      f.each do |line|
        x = line.split(",")
        if x[4].chomp.downcase === data[0].downcase && x[5].chomp.downcase === data[1].downcase
          return true
          break
        end
      end
      return false
    elsif data.length === 3
      f.each do |line|
        x = line.split(",")
        if x[3].chomp.downcase === data[0].downcase && x[4].chomp.downcase === data[1].downcase && x[5].chomp.downcase === data[2].downcase
          return true
          break
        end
      end
      return false
    else
      return false
    end
  end
end

Qube.add_distributor_name

# Using ruby
# check_data_valid method please add correct cites.csv file path
# here i am using logic for selling distribution is, if one distributor sell his distribution to someone first seller exclude that corresponding rights and buyer including that corresponding rights