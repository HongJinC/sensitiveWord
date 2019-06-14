nothandle={}--存放一句话拆分成多个小的字符串
strbool={}--存放发送语句每个字符的标志位 每个字符含有两个标志位{bool,bool}第一位为优先级高的不屏蔽字
--{false不存在于不屏蔽字库|true不屏蔽字库中存在，false不是敏感词|true是敏感词}
nosensitivewords={["曹操"]=true}
sensitivewords={["我操"]=true,["操"]=true}--敏感词库
foo = function (str)
	for i=1,#str do
		table.insert(strbool,{false,false})
	end

	--将一句话拆分的过程，存入的形式为(该字符串第一个字符在那句话中的起始位置，拆分出来的字符串)
	--例子 ABCDE拆分出来的ABC存入的形式为(1,ABC)
	for i=#str,1,-1 do  --i为个数
		for j=1,#str do		--j为起始index
			if #str-j+1>=i then
				local item={}
				table.insert(item,j)
				table.insert(item,string.sub(str,j,j+i-1))
				table.insert(nothandle,item)
			else
				break
			end
		end
	end

	return replace(str)
end


replace=function(str)

--遍历拆分出来的小字符串与敏感词组进行对比
--如果是敏感词，则将对应的字符的标志位设为false
--例子 ABCDE 拆分出来的AB是敏感词 则标志位为(false false true true true)
	for	i=1,#nothandle do
		if nosensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				strbool[k][1]=true
			end
		end
	end


	for	i=1,#nothandle do
		if sensitivewords[nothandle[i][2]]~=nil then
			for k=nothandle[i][1],nothandle[i][1]+#nothandle[i][2]-1 do
				strbool[k][2]=true
			end
		end
	end

--延续上面的例子
--根据(false false true true true) 则ABCDE=>**CDE
	for i=1,#str do
		if strbool[i][1]==false then
			--[[--下面用于判断如果下一个也是false，则不要用**而用*
			if strbool[i+1]==false then
				str1=string.sub(str,1,i-1)
				str2=string.sub(str,i+2,#str)
				str=str1.."*"..str2
				i=i+1
			end
			--]]
			if strbool[i][2]==true then
				str1=string.sub(str,1,i-1)
				str2=string.sub(str,i+1,#str)
				str=str1.."*"..str2
			end
		end
	end



	return str
end



result=foo("你是曹操，我操,操")

print(result)
