--[[
����"��,��"���е����(��+Ӣ�ı��+��) --��ʱ��֪����ô�����������������ʾ

--]]
punctuationIndexList={}--��¼������ھ��е�λ��  (index,cn/en) cn:true en:false
comparenum={}--���ڱȽϵ�����
cn_punctuation="[��|��|��|��|��|��|��|��|��|��|��|��|��|��]"--���ı��������ʽ(�����Ծ�Ϥ���)
en_punctuation="[%s|%p]"--Ӣ�ı�㣬�ո�������ʽ


cn_punctuation_list = {}--��ֳ����ı���б�
temp=string.sub(cn_punctuation,2,#cn_punctuation-1)
string.gsub(temp, '[^|]+', function(w) table.insert(cn_punctuation_list, w) end )

--����Ƿ�Ϊ���ı�� ��Ϊ��lua��"��"���ֻᱻʶ��Ϊ���ı��
function cnpunctuationcheck(content,index)
	iscnpunctuation=false
	for i=1,#cn_punctuation_list do
		if cn_punctuation_list[i]==string.sub(content,index,index+1) then
			iscnpunctuation=true
		end
	end
	return iscnpunctuation
end

--����δȥ�����ǰ������ھ��е�λ��
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

--���˵����з���
function filter(content)
	local i=1
	while string.find(string.sub(content,i,#content), cn_punctuation)~=nil or string.find(string.sub(content,i,#content), en_punctuation)~=nil do
		if string.find(content, cn_punctuation)~=nil and string.find(content, en_punctuation)~=nil then
			local cn_index=string.find(content, cn_punctuation)>i and string.find(content, cn_punctuation) or i
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
		elseif string.find(content, cn_punctuation)~=nil then--��ʱӢ�ı��Ӧ��ȫ������
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
		elseif string.find(content, en_punctuation)~=nil then--��ʱ���ı��Ӧ��ȫ������
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


function calcomparenum()--һ�������õĺ��������ڼ����comparenum
	if #punctuationIndexList==0 then return end
	for i=1,#punctuationIndexList do
		local num=punctuationIndexList[i][1]
		for j=i,1,-1 do
			local tempcount=punctuationIndexList[j][2]==true and 2 or 1
			num=num-tempcount
		end
		--����������������ķ��������⣬�������
		if i~=#punctuationIndexList then
			num=num+1
		end
		table.insert(comparenum,num)
	end
end

--ʹ����������������� ���Ѿ������˱��ľ��ӵ��ַ�������ԭ��δ����ǰ������
function caloriginalIndex(index)
	if #comparenum==0 then return index end
	if index<=comparenum[1] then
		return index
	elseif index>comparenum[#comparenum] then
		return calIndex2(index,#comparenum)
	else
		for i=1,#comparenum do
			if index<=comparenum[i] then
				return calIndex2(index,i-1)
			end
		end
	end
end

function calIndex2(index,count)
	if count>0 then
		for i=1,count do
			if punctuationIndexList[i][2]==true then
				index=index+2
			else
				index=index+1
			end
		end
	end
	return index
end


nothandle={}--���һ�仰��ֳɶ��С���ַ�����ABCDE��ֳ�����ABC�������ʽΪ(1,ABC)
strbool={}--��ŷ������ÿ���ַ��ı�־λ ÿ���ַ�����������־λ{bool,bool}��һλΪ���ȼ��ߵĲ�������
--{false�������ڲ������ֿ�|true�������ֿ��д��ڣ�false�������д�|true�����д�}
nosensitivewords={["�ܲ�"]=true}
sensitivewords={["�Ҳ�"]=true,["��"]=true,["�Բ�"]=true,["���д�"]=true}--���дʿ�
function foo(content)
	str=filter(content)
	calcomparenum()

	for i=1,#comparenum do
		--print(comparenum[i])
	end

	for i=1,#content do
		table.insert(strbool,{false,false})
	end


	--��һ�仰��ֵĹ��̣��������ʽΪ(���ַ�����һ���ַ����Ǿ仰�е���ʼλ�ã���ֳ������ַ���)
	--���� ABCDE��ֳ�����ABC�������ʽΪ(1,ABC)
	for i=#str,1,-1 do  --iΪ����
		for j=1,#str do		--jΪ��ʼindex
			if #str-j+1>=i then
				table.insert(nothandle,{j,string.sub(str,j,j+i-1)})
			else
				break
			end
		end
	end
	for k,v in pairs(nothandle) do
		print(v[2])
	end

	return replace(str,content)
end


function replace(str,content)

--������ֳ�����С�ַ��������д�����жԱ�
--��������дʣ��򽫶�Ӧ���ַ��ı�־λ��Ϊfalse
--���� ABCDE ��ֳ�����AB�����д� ���־λΪ(false false true true true)

--�����дʴ���
	for	i=1,#nothandle do
		if nosensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				local z=caloriginalIndex(k)
				strbool[z][1]=true
			end
		end
	end

--���дʴ���
	for	i=1,#nothandle do
		if sensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				local z=caloriginalIndex(k)
				strbool[z][2]=true
			end
		end
	end

--�������������
--����(false false true true true) ��ABCDE=>**CDE
	for i=1,#content do
		if strbool[i][1]==false then
			if strbool[i][2]==true then
				str1=string.sub(content,1,i-1)
				str2=string.sub(content,i+1,#content)
				content=str1.."*"..str2
			end
		end
	end


	return string.gsub(content,"%*+","***")
end


--�滻���������ַ�
function replaceIndex(content, index, replaceWorld)
	content=string.sub(content,1,index-1)..replaceWorld..string.sub(content,index+1,#content)
end

--�滻���������ַ�
function replaceIndex(content, startindex, endIndex, replaceWorld)
	content=string.sub(content,1,index-1)..replaceWorld..string.sub(content,endIndex+1,#content)
end

result=foo("a�ٱ�,sd��,�ǲ�,�ٲ�,��,�ܲ٣����ԣ��ۣ���,�٣��ܲ�,�ҡ����д�")

print(result)

