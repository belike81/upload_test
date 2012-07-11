$(function() {
  var file_input = $('input.file'),
      save_button = $('input.save'),
      progress = $('<div>').addClass('inline-upload-progress'),
      bar = $('<div>').addClass('inline-upload-bar').append(progress);


  // XHR upload definition
  file_input.bind('xhrUpload', function() {
    // Append the progress bar after the file input
    file_input.after(bar);

    $.each(this.files, function(index, file) {

      // Define the xhrUpload ajax call
      var xhrUpload = $.ajax({
        type : "POST",
        url  : file_input.data('url'),
        xhr  : function(){
          var xhr = $.ajaxSettings.xhr();
          xhr.upload.onprogress = function(response) {
            progress.css('width', (response.loaded / response.total * 100 >> 0) + '%');
            if (response.loaded === response.total) {
              progress.addClass('saving');
              progress.text('File uploaded. Please wait for transfer to finish...');
            }
          };
          xhr.onloadstart = function(){
            file_input.attr("disabled", "disabled");
            save_button.attr("disabled", "disabled");
          };
          return xhr;
        },
        beforeSend : function(xhr){
          xhr.setRequestHeader("X-XHR-Upload", "1");
          xhr.setRequestHeader("X-File-Name", file.name || file.fileName);
          xhr.setRequestHeader("X-File-Size", file.fileSize);
        },
        success : function(data, status, xhr) {
          bar.fadeOut(300, function(){
            file_input.before('<input type="hidden" value="' + data + '" name="file_path">');
            file_input.after('<div class="uploaded_to">Uploaded to: <a href="' + data + '">' + data + '</a></div>');
          }); // Remove the upload bar
        },
        complete : function(xhr, status) {
          file_input.removeAttr("disabled");
          save_button.removeAttr("disabled");
        },
        contentType : "application/octet-stream",
        dataType    : "json",
        processData : false,
        data        : file
      }); // End of $.ajax

    });  // End of $.each

  }); // End of xhrUpload.bind


  // iframe callback for legacy browsers and IE
  file_input.bind('iframeUpload', function(){
    var input   = $("<input type='file' class='inline-upload-input'>").attr('name', $(this).attr('name')),
        iframe  = $("<iframe class='inline-upload-catcher'>").hide().attr('name', 'inline-upload-catcher-' + new Date().getTime()),
        spinner = $('<img>').attr('src', '/images/ajax-loader.gif').addClass('spinner'),
        form    = $("<form enctype='multipart/form-data' method='post'>").addClass('inline-upload-form').append(input).append(auth);

    form.attr('target', iframe.attr('name'));

    $(this).after(form).after(iframe).hide();

    input.bind('complete', function(event, data){
      if (data.errors) {
        console.log('Error!');
      } else {
        console.log('Success!');
      };
      $(this).nextAll('.spinner').remove();
      console.log('Completed!');
    });

    input.change(function(){
      console.log('Starting upload');
      $(this).after(spinner);
      form.attr('action', file_input.data('url')).submit();
    });

    iframe.load(function(){
      input.trigger('complete', [$.parseJSON($(this).contents().text())]);
    });
  });

  // Check to see what technology is supported by the browser (check if it's IE or a modern browser)
  var xhr = $.ajaxSettings.xhr();
  if (xhr && xhr.upload && (xhr.upload.onprogress !== undefined)) {
    file_input.change(function(){ $(this).trigger('xhrUpload') });
  } else {
    // Trigger fallback iFrame upload
    file_input.trigger('iframeUpload');
  };

});
