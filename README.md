# Prompt-O-Matic
A minimum client for Serve-O-Matic and Draw Things API.

Prompt-O-Matic is a tiny MacOS SwiftUI Application demonstrating the basic functions for a client to the MacOS Image generation server app, Serve-O-Matic and now Draw Things too. It is forked from TinyDTClient which was extracted from the full-featured client, PromptWriter by S1D1T1 aka SoDoTo.

Dependancy: Prompt-O-Matic and its origin TinyDTClient depends on the library [RealHTTP](https://github.com/immobiliare/RealHTTP) for the low level http client stuff. Thanks to Immobillaire

The app attempts to connect to a SOM server at its default address, and has no UI for configuring server info, so SOM must be running on the same mac, with HTTP server on, at port 7860.
The app makes image requests on the API,  sending json with multiple parameters.

There's no error handling or user feedback.

To experiment with building a stable diffusion front end, start by adding to the UI -  such as a text field for negative prompt, or controls for # of steps, etc.
Use my code, or better yet try the origional cleaner code https://github.com/S1D1T1/TinyDTClient

Serve-O-Matic is my app and available from this Discord https://discord.com/invite/g2TgXpqsd8

Draw thinga is not mine and is available in the Apple app stores
