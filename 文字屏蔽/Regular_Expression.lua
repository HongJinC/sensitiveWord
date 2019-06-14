punctuationIndexList={}--记录标点所在句中的位置  (index,cn/en) cn:true en:false
filterwords=""
cn_punctuation="[，|。|、|；|‘|’|【|】|《|》|？|：|”|“]"--中文标点正则表达式
en_punctuation="[%s|%p]"--英文标点，空格正则表达式
words="asd你..??是曹操，。卧，槽，操，我。"--测试用语
cn_punctuation_list = {}--拆分出来的标点列表
temp=string.sub(cn_punctuation,2,#cn_punctuation-1)
string.gsub(temp, '[^|]+', function(w) table.insert(cn_punctuation_list, w) end )


function cnpunctuationcheck(content,index)
	iscnpunctuation=false
	for i=1,#cn_punctuation_list do
		if cn_punctuation_list[i]==string.sub(content,index,index+1) then
			iscnpunctuation=true
		end
	end
	return iscnpunctuation
end

function calIndex(index)
	for i=1,#punctuationIndexList do
		if punctuationIndexList[i][2]==true then
			index=index+2
		else
			index=index+1
		end
	end
	return index
end


function filter(content)
	local i=1
	while string.find(string.sub(content,i,#content), cn_punctuation)~=nil or string.find(string.sub(content,i,#content), en_punctuation)~=nil do
		if string.find(content, cn_punctuation)~=nil and string.find(content, en_punctuation)~=nil then
			local cn_index=string.find(content, cn_punctuation)
			local en_index=string.find(content, en_punctuation)
			if cn_index<en_index then--先找到的字符是中文字符
				i=cn_index
				if cnpunctuationcheck(content,i) then
					if #punctuationIndexList==0 then
						table.insert(punctuationIndexList,{i,true})
					else
						table.insert(punctuationIndexList,{calIndex(i),true})
					end
					content=string.sub(content,1,i-1)..string.sub(content,i+2,string.len(content))
				else
					i=cn_index+2
				end
			else					  --先找到的字符是英文字符
				i=en_index
				if #punctuationIndexList==0 then
					table.insert(punctuationIndexList,{i,false})
				else
					table.insert(punctuationIndexList,{calIndex(i),false})
				end
				content=string.sub(content,1,i-1)..string.sub(content,i+1,string.len(content))
			end
		elseif string.find(content, cn_punctuation)~=nil then
			local cn_index=string.find(content, cn_punctuation)
			if i<cn_index then
				i=cn_index
			end
			if cnpunctuationcheck(content,i) then
				if #punctuationIndexList==0 then
					table.insert(punctuationIndexList,{i,true})
				else
					table.insert(punctuationIndexList,{calIndex(i),true})
				end
				content=string.sub(content,1,i-1)..string.sub(content,i+2,string.len(content))
			else
				i=i+2
			end
		elseif string.find(content, en_punctuation)~=nil then
			local en_index=string.find(content, en_punctuation)
			i=en_index
			if #punctuationIndexList==0 then
				table.insert(punctuationIndexList,{i,false})
			else
				table.insert(punctuationIndexList,{calIndex(i),false})
			end
			content=string.sub(content,1,i-1)..string.sub(content,i+1,string.len(content))
		end
	end
	return content
end

result=filter(words)
print(result)
--[[for k,v in pairs(punctuationIndexList) do
	print("索引是"..v[1].."是否为中文标点")
	print(v[2])
end--]]
