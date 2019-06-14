--[[
对于"操,操"会有点奇怪(操+英文标点+操) --暂时不知道怎么处理，详见下面例子演示

--]]
punctuationIndexList={}--记录标点所在句中的位置  (index,cn/en) cn:true en:false
comparenum={}--用于比较的数字
cn_punctuation="[，|。|、|；|‘|’|【|】|《|》|？|：|”|“]"--中文标点正则表达式(还可以据悉添加)
en_punctuation="[%s|%p]"--英文标点，空格正则表达式


cn_punctuation_list = {}--拆分出来的标点列表
temp=string.sub(cn_punctuation,2,#cn_punctuation-1)
string.gsub(temp, '[^|]+', function(w) table.insert(cn_punctuation_list, w) end )

--检查是否为中文标点 因为在lua中"边"等字会被识别为中文标点
function cnpunctuationcheck(content,index)
	iscnpunctuation=false
	for i=1,#cn_punctuation_list do
		if cn_punctuation_list[i]==string.sub(content,index,index+1) then
			iscnpunctuation=true
		end
	end
	return iscnpunctuation
end

--计算未去除标点前，标点在句中的位置
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

--过滤掉所有符号
function filter(content)
	local i=1
	while string.find(string.sub(content,i,#content), cn_punctuation)~=nil or string.find(string.sub(content,i,#content), en_punctuation)~=nil do
		if string.find(content, cn_punctuation)~=nil and string.find(content, en_punctuation)~=nil then
			local cn_index=string.find(content, cn_punctuation)>i and string.find(content, cn_punctuation) or i
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
		elseif string.find(content, cn_punctuation)~=nil then--此时英文标点应经全部过滤
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
		elseif string.find(content, en_punctuation)~=nil then--此时中文标点应经全部过滤
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


function calcomparenum()--一个过渡用的函数，用于计算出comparenum
	if #punctuationIndexList==0 then return end
	for i=1,#punctuationIndexList do
		local num=punctuationIndexList[i][1]
		for j=i,1,-1 do
			local tempcount=punctuationIndexList[j][2]==true and 2 or 1
			num=num-tempcount
		end
		--！！！！！！下面的方法有问题，还需测试
		if i~=#punctuationIndexList then
			num=num+1
		end
		table.insert(comparenum,num)
	end
end

--使用这个函数是在用于 把已经过滤了标点的句子的字符索引还原到未过滤前的索引
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


nothandle={}--存放一句话拆分成多个小的字符串，ABCDE拆分出来的ABC存入的形式为(1,ABC)
strbool={}--存放发送语句每个字符的标志位 每个字符含有两个标志位{bool,bool}第一位为优先级高的不屏蔽字
--{false不存在于不屏蔽字库|true不屏蔽字库中存在，false不是敏感词|true是敏感词}
nosensitivewords={["曹操"]=true}
sensitivewords={["我操"]=true,["操"]=true,["卧槽"]=true,["敏感词"]=true}--敏感词库
function foo(content)
	str=filter(content)
	calcomparenum()

	for i=1,#comparenum do
		--print(comparenum[i])
	end

	for i=1,#content do
		table.insert(strbool,{false,false})
	end


	--将一句话拆分的过程，存入的形式为(该字符串第一个字符在那句话中的起始位置，拆分出来的字符串)
	--例子 ABCDE拆分出来的ABC存入的形式为(1,ABC)
	for i=#str,1,-1 do  --i为个数
		for j=1,#str do		--j为起始index
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

--遍历拆分出来的小字符串与敏感词组进行对比
--如果是敏感词，则将对应的字符的标志位设为false
--例子 ABCDE 拆分出来的AB是敏感词 则标志位为(false false true true true)

--不敏感词处理
	for	i=1,#nothandle do
		if nosensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				local z=caloriginalIndex(k)
				strbool[z][1]=true
			end
		end
	end

--敏感词处理
	for	i=1,#nothandle do
		if sensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				local z=caloriginalIndex(k)
				strbool[z][2]=true
			end
		end
	end

--延续上面的例子
--根据(false false true true true) 则ABCDE=>**CDE
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


--替换索引所在字符
function replaceIndex(content, index, replaceWorld)
	content=string.sub(content,1,index-1)..replaceWorld..string.sub(content,index+1,#content)
end

--替换索引所在字符
function replaceIndex(content, startindex, endIndex, replaceWorld)
	content=string.sub(content,1,index-1)..replaceWorld..string.sub(content,endIndex+1,#content)
end

result=foo("a操边,sd你,是操,操曹,操,曹操，。卧，槽，操,操，曹操,我。敏感词")

print(result)

