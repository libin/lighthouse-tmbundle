function openInBrowser(link) {
  if (link.href != null) {
    TextMate.system('open ' + link.href, null);
  }
  return false;
}

function changeStatus(select, project) {
  TextMate.isBusy = true;

  var newState = select[select.selectedIndex].value, ticketId = select.id.replace('lh_ticket_', '');

  var query = '"' + ENV['TM_BUNDLE_SUPPORT'] + '/state_changer.rb"' + ' -state=' + newState + ' -id=' + ticketId + ' -account=' + ENV['TM_LH_ACCOUNT'] + ' -token=' + ENV['TM_LH_TOKEN'] + ' -project=' + project;

  results = TextMate.system(query, null);

  if (results.outputString == "done") {
    document.getElementById('number_' + ticketId).style.color = STATE_HASH[newState];
    document.getElementById('link_' + ticketId).style.color   = STATE_HASH[newState];
  }

  TextMate.isBusy = false;
}

function changeProject(select) {
  TextMate.isBusy = true;
  
  var newProject = select[select.selectedIndex].value;
  var query = '"' + ENV['TM_BUNDLE_SUPPORT'] + '/project_changer.rb"' + ' -project=' + newProject + ' -account=' + ENV['TM_LH_ACCOUNT'] + ' -token=' + ENV['TM_LH_TOKEN'];
  
  result = TextMate.system(query, null);
  
  output_string = result.outputString
  if (output_string) {
    document.getElementById('tickets').innerHTML = output_string;
  }
  
  TextMate.isBusy = false;
}

function toggleBody(ticketId) {
  body_element = document.getElementById('body_' + ticketId);
  if (body_element.style.display == 'none')
    body_element.style.display = '';
  else
    body_element.style.display = 'none';
}

function e_sh(s){
	return s
	.toString()
	.replace(/\x27/g,"’")
	.replace(/\"/g,'\\\"')
	;
}

window.alert = function(s){
	TextMate.system('"$DIALOG" -e -p \'{messageTitle="JavaScript";informativeText="'+e_sh(s)+'";}\'', null);
};