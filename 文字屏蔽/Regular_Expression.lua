punctuationIndexList={}--��¼������ھ��е�λ��  (index,cn/en) cn:true en:false
filterwords=""
cn_punctuation="[��|��|��|��|��|��|��|��|��|��|��|��|��|��]"--���ı��������ʽ
en_punctuation="[%s|%p]"--Ӣ�ı�㣬�ո�������ʽ
words="asd��..??�ǲܲ٣����ԣ��ۣ��٣��ҡ�"--��������
cn_punctuation_list = {}--��ֳ����ı���б�
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
			if cn_index<en_index then--���ҵ����ַ��������ַ�
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
			else					  --���ҵ����ַ���Ӣ���ַ�
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
	print("������"..v[1].."�Ƿ�Ϊ���ı��")
	print(v[2])
end--]]
