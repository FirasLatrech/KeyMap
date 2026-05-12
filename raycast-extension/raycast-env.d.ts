/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {
  /** Default Direction - Direction used by the Convert Clipboard command. */
  "defaultDirection": "auto" | "en2ar" | "ar2en" | "en2fr" | "fr2en",
  /** AZERTY support - Enable French AZERTY conversion in the picker. */
  "azerty": boolean,
  /** Notifications - Show a toast confirming the conversion direction. */
  "toast": boolean
}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `convert` command */
  export type Convert = ExtensionPreferences & {}
  /** Preferences accessible in the `convert-clipboard` command */
  export type ConvertClipboard = ExtensionPreferences & {}
}

declare namespace Arguments {
  /** Arguments passed to the `convert` command */
  export type Convert = {}
  /** Arguments passed to the `convert-clipboard` command */
  export type ConvertClipboard = {}
}

