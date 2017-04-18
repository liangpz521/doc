### solr加入中文拼音和首字母检索功能



前提是要下载源码

https://github.com/Jonathan-Wei/pinyinTokenFilter.git



* 下载后修改PinyinTransformTokenFilter.java第160行代码(原代码只支持两者之一,不能同时存在)

```
//					this.terms = this.firstChar ? getPyShort(chinese): GetPyString(chinese); 原代码
					//以下是修改后的代码,支持全拼和首字母
					this.terms = getPyShort(chinese);
					this.terms.addAll(GetPyString(chinese));
```

修改代码后 生成jar包pinyinTokenFilter-1.0.0-RELEASE.jar

* 下载 pinyin4j-2.5.0.jar
* 两个jar包下载好后放到  solr/webapps/solr/WEB-INF/lib下





修改schema.xml 增加以下信息

```
<fieldType name="text_suggest" class="solr.TextField">
	<analyzer type="index">
		<tokenizer class="solr.LowerCaseTokenizerFactory"/>
		<filter class="solr.NGramTokenizerFactory" minGramSize="1" maxGramSize="80"/>
		<filter class="me.dowen.solr.analyzers.PinyinTransformTokenFilterFactory" isOutChinese="true" firstChar="true" minTermLength="1"/>
		<filter class="solr.LowerCaseFilterFactory" />
	</analyzer>
	<analyzer type="query">
		<tokenizer class="solr.WhitespaceTokenizerFactory"/>
		<filter class="solr.LowerCaseFilterFactory" />
	</analyzer>
</fieldType>
```

这里注意下，这个插件支持拼音全拼以及缩写，但是当配置缩写和全频一起使用的时候，貌似不大好使。所以我这里也只配置了一个缩写(原代码是这样 ,但是修改过源码的程序是可以支持两种的)

看下参数的一些说明：

* isOutChinese：是否保留原输入中文词元。可选值：true(默认)/false


* firstChar：输出完整拼音格式还是输出简拼。简拼输出是由原中文词元的各单字的拼音结果的首字母组成的。可选值：true(默认)/false
* minTermLength：仅输出字数大于或等于minTermLenght的中文词元的拼音结果。默认值为2。



对应字段的配置

```
       <field name="search" type="text_suggest" indexed="true" stored="true" multiValued="true" />

```





