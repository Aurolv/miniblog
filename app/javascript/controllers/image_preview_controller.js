import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "image", "meta", "filename", "placeholder"]
  static values = {
    filenameDefault: String
  }

  connect() {
    this.defaultName = this.filenameDefaultValue || "File not selected"
  }

  preview() {
    const [file] = this.inputTarget.files || []

    if (file) {
      this.showPreview(file)
    } else {
      this.resetPreview()
    }
  }

  showPreview(file) {
    const url = URL.createObjectURL(file)
    this.imageTarget.src = url
    this.filenameTarget.textContent = file.name

    this.previewTarget.classList.remove("hidden")
    this.imageTarget.classList.remove("hidden")
    this.metaTarget.classList.remove("hidden")
    this.metaTarget.textContent = `New file: ${file.name}`
    this.placeholderTarget.classList.add("hidden")
  }

  resetPreview() {
    this.filenameTarget.textContent = this.defaultName
    if (this.imageTarget.src) URL.revokeObjectURL(this.imageTarget.src)
    this.imageTarget.src = ""
    this.previewTarget.classList.add("hidden")
    this.imageTarget.classList.add("hidden")
    this.metaTarget.classList.add("hidden")
    this.metaTarget.textContent = ""
    this.placeholderTarget.classList.remove("hidden")
  }
}
