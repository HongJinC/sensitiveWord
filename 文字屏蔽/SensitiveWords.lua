nothandle={}--���һ�仰��ֳɶ��С���ַ���
strbool={}--��ŷ������ÿ���ַ��ı�־λ ÿ���ַ�����������־λ{bool,bool}��һλΪ���ȼ��ߵĲ�������
--{false�������ڲ������ֿ�|true�������ֿ��д��ڣ�false�������д�|true�����д�}
nosensitivewords={["�ܲ�"]=true}
sensitivewords={["�Ҳ�"]=true,["��"]=true}--���дʿ�
foo = function (str)
	for i=1,#str do
		table.insert(strbool,{false,false})
	end

	--��һ�仰��ֵĹ��̣��������ʽΪ(���ַ�����һ���ַ����Ǿ仰�е���ʼλ�ã���ֳ������ַ���)
	--���� ABCDE��ֳ�����ABC�������ʽΪ(1,ABC)
	for i=#str,1,-1 do  --iΪ����
		for j=1,#str do		--jΪ��ʼindex
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

--������ֳ�����С�ַ��������д�����жԱ�
--��������дʣ��򽫶�Ӧ���ַ��ı�־λ��Ϊfalse
--���� ABCDE ��ֳ�����AB�����д� ���־λΪ(false false true true true)
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

--�������������
--����(false false true true true) ��ABCDE=>**CDE
	for i=1,#str do
		if strbool[i][1]==false then
			--[[--���������ж������һ��Ҳ��false����Ҫ��**����*
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



result=foo("���ǲܲ٣��Ҳ�,��")

print(result)
