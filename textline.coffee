###*
TextLine.js  -version 0.0.1  --> some code to make things work
Created by Chen --> https://github.com/cl-
License: https://
You can convert this JavaScript code to CoffeeScript code via: http://js2coffee.org/
###
SAMPLE_CODE_TEST_N_USAGE_EXAMPLE = ->
  #NOTE: this is a function reference.
  MAIN_SAMPLE_CODE_TEST_N_USAGE_EXAMPLE = ->
    wikipediaContent__Alexander_the_Great = $("#mw-content-text")[0]
    
    #Simulated selection of the nodeThatsOnTheLine. 6 9 11
    aNode1 = wikipediaContent__Alexander_the_Great.children[4].children[8] #Macedon //m
    aNode2 = wikipediaContent__Alexander_the_Great.children[4].children[11] #largest empires //m
    aNode3 = wikipediaContent__Alexander_the_Great.children[4].children[6] #Greek -to-> Macedon //s //a-m
    
    #READ HERE: Code Test & Usage Example - of the actual API calls you can use
    getString_atLineEnd aNode1
    getString_atLineEnd aNode2 #May not work perfectly. Because it's not text node.
    getString_atLineEnd aNode3
    el = document.createElement("div")
    el.innerHTML = "<a href='test1'>test01</a><a href='test2'>test02</a><a href='test3'>test03</a>"
    insertNode_atLineEnd aNode1, el
    el2 = document.createElement("div")
    el2.innerHTML = "<a href='test4'>test04</a><a href='test5'>test05</a><a href='test6'>test06</a>"
    insertNode_atLineEnd aNode2, el2
    return
  window.location.href = "http://en.wikipedia.org/wiki/Alexander_the_Great"
  window.addEventListener "load", MAIN_SAMPLE_CODE_TEST_N_USAGE_EXAMPLE, false
  return

#==================================================
# Exposed Functions - These are the abstracted APIs that you can use.
#=========================
getNode_atLineEnd = (aNodeOnTheTargetLine) ->
  containerDOM = aNodeOnTheTargetLine.parentElement
  containerPos = getPosition(containerDOM) #maximum width per line
  analyzed_textline_node = getNode_atLineEnd_afterStartNode(containerDOM, aNodeOnTheTargetLine, containerPos)
  analyzed_textline_node["parentElement"] = containerDOM
  analyzed_textline_node
insertNode_atLineEnd = (aNodeOnTheTargetLine, nodeToInsert) ->
  analyzed_textline_node = getNode_atLineEnd(aNodeOnTheTargetLine)
  atn = analyzed_textline_node
  insertNode_intoNode atn.node, atn.textNode, atn.numOffsetChars_toLineEnd, nodeToInsert #returns inserted node
getString_atLineEnd = (aNodeOnTheTargetLine) ->
  analyzed_textline_node = getNode_atLineEnd(aNodeOnTheTargetLine)
  atn = analyzed_textline_node
  atn.wordArr.slice(0, atn.sliceTillIdx).join " "
getWord_atLineEnd = (aNodeOnTheTargetLine) ->
  analyzed_textline_node = getNode_atLineEnd(aNodeOnTheTargetLine)
  atn = analyzed_textline_node
  atn.wordArr[atn.word_atLineEnd_idx]

#==================================================
# Internal Functions - The concrete implementation details.
#=========================
getPosition = (aNodeObj) ->
  rg = document.createRange()
  rg.selectNodeContents aNodeObj
  boundingRect = rg.getBoundingClientRect()
  boundingRect
getHeightWidth = (aNodeObj) ->
  boundingRect = getPosition(aNodeObj)
  width: boundingRect.width
  height: boundingRect.height
getHeightWidth_viaOffset = (aNodeObj, numCharactersToOffset) ->
  rg = document.createRange()
  rg.setStart aNodeObj, 0
  rg.setEnd aNodeObj, numCharactersToOffset
  boundingRect = rg.getBoundingClientRect()
  width: boundingRect.width
  height: boundingRect.height

#---------------
getTextNode = (aNode) -> ##RECURSIVE  //#LIMITED: Can only get one child TextNode  //#FUTURE: Handle node that has MULTIPLE children TextNode
  return aNode  if aNode.nodeName is "#text"
  
  #else if not TextNode
  return null  if aNode.childNodes.length is 0
  
  #else if has childNodes
  i = 0

  while i < aNode.childNodes.length
    currNode = getTextNode(aNode.childNodes[i])
    return currNode  if currNode.nodeName is "#text"
    ++i
  return
insertNode_intoNode = (targetNode, itsTextNode, numOffsetChars_toInsertAfter, nodeToInsert) ->
  if targetNode.nodeName is "#text"
    insertNode_intoTextNode itsTextNode, numOffsetChars_toInsertAfter, nodeToInsert
  else ##CONSIDER_2014-08-25 this could completely replace insertNode_intoTextNode(). But this is less readable though.
    textAfterLineEnd = itsTextNode.nodeValue.substr(numOffsetChars_toInsertAfter, itsTextNode.nodeValue.length)
    itsTextNode.nodeValue = itsTextNode.nodeValue.substr(0, numOffsetChars_toInsertAfter)
    targetNode.parentElement.insertBefore nodeToInsert, targetNode.nextSibling
    elemClone_forAfterLineEnd = targetNode.cloneNode(true)
    getTextNode(elemClone_forAfterLineEnd).nodeValue = textAfterLineEnd
    targetNode.parentElement.insertBefore elemClone_forAfterLineEnd, nodeToInsert.nextSibling
    docFragment = document.createDocumentFragment()
    docFragment #for:debugging
insertNode_intoTextNode = (theTextNode, numOffsetChars_toInsertAfter, nodeToInsert) -> #REPLACED: //function replaceNode_withMultiple(nodeToRemove, nodeToUse){}
  docFragment = document.createDocumentFragment()
  
  #you can directly use numOffsetChars_toInsertAfter without +1 --> because number starts from 1 while slice/substr starts from 0.
  docFragment.appendChild document.createTextNode(theTextNode.nodeValue.substr(0, numOffsetChars_toInsertAfter))
  docFragment.appendChild nodeToInsert
  docFragment.appendChild document.createTextNode(theTextNode.nodeValue.substr(numOffsetChars_toInsertAfter, theTextNode.nodeValue.length))
  theTextNode.parentElement.replaceChild docFragment, theTextNode ##USAGE: node.replaceChild(newchild, existingchild); ///85041dceabd432af6f48dec45bbbcb01
  docFragment #for:debugging

#=========================
##CONSIDER_2014-08-10: Should we get the node at the end of the lineWidth, or the node immediately after the end of the lineWidth??
getNode_atLineEnd_afterStartNode = (containerDOM, startNode, containerPos) -> #the containerDOM gives the lineWidth and lineHeight
  startIdx = Array::indexOf.call(containerDOM.childNodes, startNode) #startNode must be a child of the containerDOM ///ba6bf4f1f6c241b146e302ce4001c797
  startNodePos = getPosition(startNode)
  
  #Get the minimum unit height for our targeted line. (The anchor text may be across 2 lines.)
  minLineHeight = containerPos.height
  i = startIdx - 1

  while i < (startIdx + 1) + 1
    currNodeHW = getHeightWidth(containerDOM.childNodes[i])
    minLineHeight = currNodeHW.height  if currNodeHW.height < minLineHeight
    ++i
  
  #Note that superscript (resource reference notation) has a smaller font (height 14) than regular text (height 16).
  #But the difference is very small. Also, superscripts will NEVER be considered because superscripts are ALWAYS PRECEDED BY THE FULLSTOP, which is regular text, thus preventing the code above from reaching the superscript.
  estLineHeight = minLineHeight
  
  #Now we can look through the nodes after the Anchor (href link) element node, to find the node that spans across 2 lines (2x height).
  #THERE ARE 3 POSSIBLE CASES - (1) TextNode/Anchor across end, (2) Anchor across end, (3) OneNode at end, NextNode on next line
  the_lineEnd_node = null #REPLACES:  //var multiLine_lineEnd_node = null;  //var multiLineNode = null;
  isMultiLine = null
  
  #EDGE CASE: Must start from startIdx itself. Do not start from startIdx+1 --> because the startNode itself may be at the line-break!!
  i = startIdx #Must use childNodes.length (not childElementCount) to include the #text nodes.

  while i < containerDOM.childNodes.length
    currNodePos = getPosition(containerDOM.childNodes[i])
    
    #Detect Case: Multi-Line node that goes across the line-end.
    if currNodePos.height > estLineHeight * 1.8
      the_lineEnd_node = containerDOM.childNodes[i]
      isMultiLine = true
      break
    
    #Case here after Elimination: CurrNode is Single-Line node. It does not go across the line-end.
    #Therefore, if NextNode has a smaller "left", then it means that the line-end has occurred.
    #WARNING: Do not use "top" or "bottom". They are relative within a line, and are undependable for determining line-end.
    else
      nextNodePos = getPosition(containerDOM.childNodes[i + 1])
      
      #This only works if the currNode is confirmed to be confined within one line and not multiple lines.
      if currNodePos.right is containerPos.right and nextNodePos.left <= currNodePos.left #Must be less-or-equal - CurrNode could have started at the start of line.
        the_lineEnd_node = containerDOM.childNodes[i]
        isMultiLine = false
        break
    ++i
  #end if-else
  #end for-loop iterating on childNodes after the Anchor.
  theTextNode = null
  
  ##GOTCHA: There may be text-elements that are not textNode.
  ##FUTURE: Handle cases in which text-elements are not textNode.
  if the_lineEnd_node.nodeName is "#text"
    theTextNode = the_lineEnd_node
  else theTextNode = getTextNode(the_lineEnd_node)  unless the_lineEnd_node.nodeName is "#text"
  
  #Determine the word before line break -- by inspecting the theTextNode using offset characters
  wordArr = theTextNode.nodeValue.split(" ") #IMPT: nodeValue -- unique to #text nodes, rather than elements.
  if isMultiLine is false
    return (
      node: the_lineEnd_node
      textNode: theTextNode
      numOffsetChars_toLineEnd: theTextNode.nodeValue.length
      wordArr: wordArr
      sliceTillIdx: wordArr.length
      word_atLineEnd_idx: wordArr.length - 1
    )
  
  #else isMultiLine === true
  i = 0

  while i < wordArr.length
    subsetOfText = wordArr.slice(0, i + 1).join(" ")
    numCharsToOffset = subsetOfText.length
    subsetOfText_HW = getHeightWidth_viaOffset(theTextNode, numCharsToOffset)
    if subsetOfText_HW.height > estLineHeight * 1.8
      return (
        node: the_lineEnd_node
        textNode: theTextNode
        numOffsetChars_toLineEnd: wordArr.slice(0, i).join(" ").length
        wordArr: wordArr #end return AnalyzedTextlineNode_Object
        sliceTillIdx: i
        word_atLineEnd_idx: i - 1
      )
    ++i
  return
#end for-loop
#end function getNode_atLineEnd_afterStartNode

#-------------------------
#OLD_VERSION: Do not do this in future implementations.
#getNode_beyondLineWidth_afterStartNode_v2 ==> getNode_atLineEnd_afterStartNode
getNode_beyondLineWidth_afterStartNode_v1 = (containerDOM, startNode, lineWidth) -> #the containerDOM gives the LineWidth
  cumulativeLength = 0
  cumulativeLines = 0
  i = 0 #Must use childNodes.length (not childElementCount) to include the #text nodes.

  while i < containerDOM.childNodes.length
    cumulativeLength += getWidth(containerDOM.childNodes[i])
    cumulativeLines = Math.floor(cumulativeLength / lineWidth)
    ++i
  return
libName = "textline"
libVersionNum = "0.0.1"
console.info "TextLine.js  -version 0.0.1  --> some code to make things work\n", "Created by Chen --> https://github.com/cl-\n", "License: https://\n", "You can convert this JavaScript code to CoffeeScript code via: http://js2coffee.org/\n"

#=========================
(->
  loadDependency_all = ->
    # ["https://raw.githubusercontent.com/blueimp/JavaScript-MD5/master/js/md5.js"];
    ##CONSIDER Array.prototype.push.apply(jsNameList,["abc", "def"]);
    
    #Create loadSequence, which has unlinked names (to be replaced with element-functions later).
    #REPLACED: //var loadSequence = [load_md5, load_ossut];
    #create a loadSequence with same length as jsNameList
    
    #Create linked loadSequence: Link element-functions together.
    #Inject successor loader function into predecessor loader function.
    #shorter name - so that code below is shorter.
    emptyFunc = ->
    finalFunc = ->
      ossut libName, libVersionNum
      return
    
    # for (var i=0; i<loadSequence.length-1; ++i){
    #   //var nextDepdLoader = emptyFunc; if ((i+1)<loadSequence.length){ nextDepdLoader = loadSequence[i+1]; }
    #   nextDepdLoader = loadSequence[i+1];
    #   loadSequence[i]( nextDepdLoader );
    # }
    
    #Execute the loadSequence
    #Executing the first dependency-loader, will set of the chain reaction of executing the rest of them.
    
    #---------------
    createDepdLoader_immutable = (dependencySrc, fn) ->
      ->
        dep = document.createElement("script")
        dep.src = dependencySrc
        dep.type = "text/javascript"
        document.getElementsByTagName("head")[0].appendChild dep
        dep.addEventListener "load", fn #Chrome, Firefox //Not supported by Internet Explorer
        return
    createDepdLoader_mutable = (dependencySrc) ->
      (fn) ->
        dep = document.createElement("script")
        dep.src = dependencySrc
        document.getElementsByTagName("head")[0].appendChild dep
        dep.addEventListener "load", fn #Chrome, Firefox //Not supported by Internet Explorer
        return
    
    #---------------
    load_md5 = (fn) ->
      md5 = document.createElement("script")
      md5.src = ""
      document.getElementsByTagName("head").appendChild md5
      md5.addEventListener "load", fn #Chrome, Firefox //Not supported by Internet Explorer
      return
    load_ossut = (fn) ->
      ossut = document.createElement("script")
      ossut.src = ""
      document.getElementsByTagName("head").appendChild ossut
      ossut.addEventListener "load", fn #Chrome, Firefox //Not supported by Internet Explorer
      return
    
    #---------------
    ossut = (libName, libVersionNum) ->
      getRequest = (url, success, failure) ->
        request = makeRequestObject()
        request.open "GET", url, true
        request.send null
        request.onreadystatechange = ->
          if request.readyState is 4
            if request.status is 200
              success request.responseText
            else failure request.status, request.statusText  if failure
          return

        return
      postRequest = (url, jsonData, success, failure) ->
        request = makeRequestObject()
        request.open "POST", url, true
        request.send jsonData
        request.onreadystatechange = ->
          if request.readyState is 4
            if request.status is 200
              success request.responseText
            else failure request.status, request.statusText  if failure
          return

        return
      runIncrementCount = ->
        unless Firebase
          firebaseScript = document.createElement("script")
          firebaseScript.src = "https://cdn.firebase.com/js/client/1.0.21/firebase.js"
          firebaseScript.addEventListener "load", incrementCount
        else #if(Firebase)
          incrementCount()
        return
      incrementCount = ->
        getRequest "https://freegeoip.net/json/", (getData) ->
          getData = JSON.parse(getData)
          
          #postRequest("https://ossut.firebaseio.com/raw/"+"textline/", JSON.stringify( {datetime:(new Date()).getTime(), on:[window.location.hostname,window.location.href], unique:md5(window.location.hostname+getData.ip), in:getData} ), function(){});
          uniqueCaller = window.location.hostname.toLowerCase().replace(/[:#$%\[\]\/]/g, "XX").replace(/\./g, "OO")
          uniqueCounter = md5(window.location.hostname + getData.ip)
          firebaseRef = new Firebase("https://ossut.firebaseio.com/raw/" + libName + "/" + libVersionNum.replace(/\./g, "-") + "/" + uniqueCaller + "/" + uniqueCounter)
          firebaseRef.push
            datetime: [
              (new Date()).getTime()
              (new Date()).toGMTString()
            ]
            on: [
              window.location.hostname
              window.location.href
            ]
            in: getData
          , closeIncrementCount
          return

        return
      #end getRequest's Success Func
      closeIncrementCount = ->
      
      #Do not make Firebase goOffline. It affects ALL Firebase connections.
      #Hence, calling this may accidentally disconnect the user's other Firebase connections, if other Firebase connections are present.
      #Firebase.goOffline(); //Manually disconnects the Firebase client from the server and disables automatic reconnection.
      makeRequestObject = ->
        try
          return new XMLHttpRequest()
        try
          return new ActiveXObject("Msxml2.XMLHTTP")
        try
          return new ActiveXObject("Microsoft.XMLHTTP")
        throw new Error("Could not create HTTP request object.")return
      #//show(typeof(makeRequestObject()));
      incrementCount()
      return
    jsNameList = ["https://rawgit.com/blueimp/JavaScript-MD5/master/js/md5.js"]
    jsNameList = jsNameList.concat(["https://cdn.firebase.com/js/client/1.0.21/firebase.js"])
    loadSequence = []
    i = 0

    while i < jsNameList.length
      loadSequence.push jsNameList[i]
      ++i
    loadSeq = loadSequence
    loadSeq[loadSeq.length - 1] = createDepdLoader_immutable(loadSeq[loadSeq.length - 1], finalFunc)
    i = (loadSeq.length - 1) - 1

    while i >= 0
      loadSeq[i] = createDepdLoader_immutable(jsNameList[i], loadSeq[i + 1])
      --i
    loadSeq[0]()
    return
  #end ossut()
  #end loadDependency_all()
  setTimeout loadDependency_all, 60 * 1000
  return
)()