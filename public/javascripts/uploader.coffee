class Uploader
  constructor: (@model) ->
    @$importForm = $('#importForm')
    @$importButton   = @$importForm.find('#importButton')
    @$importAction   = @$importForm.find('#importAction')
    @$importProgress = @$importForm.find('#importProgress')
    @initForm()

  initForm: () ->
    @$importForm.ajaxForm
      url: "/baseline_upload"
      beforeSend: () =>
        @$importProgress.show()
      uploadProgress: (e, position, total, percent) =>
        @updateProgress(percent)
      success: () =>
        @updateProgress(100)
      complete: (xhr) =>
        @completeUpload(xhr.responseJSON)

    @$importAction.change () =>
      @$importForm.submit()

    @$importButton.click (e) =>
      e.preventDefault()
      @$importAction.click()

  updateProgress: (percent) ->
    @$importProgress.find('.progress-bar').width(percent)

  completeUpload: (response) ->
    @model.fetch()

window.Uploader = Uploader
