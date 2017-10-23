function class_properties = GetProperties(varagin)
 if ~isempty(varagin{1})&&~isempty(varagin{2})&&~isempty(varagin{3})
     classname = ['?',varagin{1}];
     class_info = eval(classname);
     PropertyList = class_info.PropertyList;
     property_attribute = varagin{2};
     classlevel = varagin{3};
     property_list = properties(varagin{1});
     class_properties = {};
     if classlevel==0
         for index = 1 : length(property_list)
             if strcmp(PropertyList(index,1).DefiningClass.Name,varagin{1})
                 if strcmp(PropertyList(index).GetAccess,property_attribute)
                class_properties{end+1} = property_list{index};
                 end
             end
         end
     end
 end
end