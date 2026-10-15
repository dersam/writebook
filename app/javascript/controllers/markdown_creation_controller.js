import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  preventFileUpload(event) {
    if (event.dataTransfer?.files.length) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
