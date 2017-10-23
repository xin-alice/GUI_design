%this class is the superclass of the geometry classes. the class is in
%charge of converting the public variables to symbolic properties. 
classdef clSymbolicProperties < handle
	properties(Access = private)
		%save name of properteis, that should not be able to convert to
		%numeric symbolic variable
		cell_str_exceptions = {}
		%save the flag, if the variable have been convert to symbolic
		%properties
		symbolic_properties_enabled = 0;
		%save all converted symbolic properties
		cell_obj_numsym = {};
	end
	methods
		function obj = clSymbolicProperties
			%obj.cell_str_exceptions = {'cell_str_exceptions','symbolic_properties_enabled','cell_obj_numsym'};
        end
        function OverwriteGeometryDataWithOptimizedParameters(obj,stct_optimum)
            plist = properties(obj);
            for i=1:numel(plist)
                if isfield(stct_optimum,plist{i})
                    obj.(plist{i}) = stct_optimum.(plist{i});
                end
            end
        end
		function AddExceptionsOfSymbolicProperties(obj,varargin)
			obj.cell_str_exceptions = [obj.cell_str_exceptions,varargin];
		end
		%>@brief convert the properties to clNumSym except where it does
		%>not make any sense at all, specified by a cell containing the
		%>property names as strings
		function ConvertToCombinedNumericSymbolic(obj)
			plist = properties(obj);
			for i=1:numel(plist)
				skip = 0;
				for j=1:numel(obj.cell_str_exceptions)
					if strcmp(char(plist{i}),obj.cell_str_exceptions{j}) || isempty(obj.(plist{i}))
						skip = 1;
					end
				end
				if skip == 0
% 					assignin('base', char(plist{i}), obj.(plist{i}));
					obj.(plist{i}) = LPNUtilities.clNumSym(char(plist{i}),obj.(plist{i}));
					obj.cell_obj_numsym{end+1} = obj.(plist{i});
				end
			end
			obj.symbolic_properties_enabled = 1;
%			obj.SaveSymbolicPropertiesInStruct(str_struct);
		end
		%superclass can not read proteced properties of subclass	
% 		function ConvertToCombinedNumericSymbolic(obj)
% 			mc = metaclass(obj);
% 			plist = {mc.PropertyList.Name};
% 			for i=1:numel(plist)
% 				skip = 0;
% 				for j=1:numel(obj.cell_str_exceptions)
% 					if strcmp(char(plist{i}),obj.cell_str_exceptions{j}) || isempty(obj.(plist{i}))
% 						skip = 1;
% 					end
% 				end
% 				if skip == 0
% % 					assignin('base', char(plist{i}), obj.(plist{i}));
% 					obj.(plist{i}) = LPNUtilities.clNumSym(char(plist{i}),obj.(plist{i}));
% 					obj.cell_obj_numsym{end+1} = obj.(plist{i});
% 				end
% 			end
% 			obj.symbolic_properties_enabled = 1;
% %			obj.SaveSymbolicPropertiesInStruct(str_struct);
% 		end
		function cell_obj_numsym = GetCellSymbolicVariable(obj)
			cell_obj_numsym = obj.cell_obj_numsym;
		end
% 		%>brief save the properties in struct
% 		function SaveSymbolicPropertiesInStruct(obj,str_struct)
% 			plist = properties(obj);
% 			for i=1:numel(plist)
% 				skip = 0;
% 				for j=1:numel(obj.cell_str_exceptions)
% 					if strcmp(char(plist{i}),obj.cell_str_exceptions{j})
% 						skip = 1;
% 					end
% 				end
% 				if skip == 0 && isa(obj.(plist{i}),'LPNUtilities.clNumSym')
% 					obj.(plist{i}).AssignInBase(str_struct);
% % 					obj.(plist{i}) = clNumSym(char(plist{i}),obj.(plist{i}));
% 				end
% 			end
% 		end
		function enabled = SymbolicPropertiesEnabled(obj)
			enabled = obj.symbolic_properties_enabled;
		end
	end
end