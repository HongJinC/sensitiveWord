laststr=""
index=0
repeatList={}
foo = function (str)
	index=index+1
	i=#str
	print(str.."����"..index.."����"..i)
	if i == 1 then
		for i=1,#repeatList do
			if str==repeatList[i] then
				return
			end
		end
		local item={}
		--item[1]=str
		--item[2]=strsub
		--table.insert(repeatList,item)
		table.insert(repeatList,str)
		laststr=laststr..str
	else
		foo(string.sub(str,1,#str-1))
		foo(string.sub(str,2,#str))
	end
end

foo("hong",4)
print(laststr.."����֮��")
