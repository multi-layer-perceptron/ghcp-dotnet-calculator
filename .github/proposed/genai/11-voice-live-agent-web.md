---
lab:
  title: "Develop an Azure AI Voice Live voice agent"

  description: "Learn how to create a web app to enable real-time voice interactions with an Azure AI Voice Live agent."
---

\n\nDevelop an Azure AI Voice Live voice agent

In this exercise, you complete a Flask-based Python web app based that enables real-time voice interactions with an agent. You add the code to initialize the session, and handle session events. You use a deployment script that: deploys the AI model; creates an image of the app in Azure Container Registry (ACR) using ACR tasks; and then creates an Azure App Service instance that pulls the the image. To test the app you will need an audio device with microphone and speaker capabilities.

While this exercise is based on Python, you can develop similar applications other language-specific SDKs; including:

\n\n[Azure VoiceLive client library for .NET](https://www.nuget.org/packages/Azure.AI.VoiceLive/)

Tasks performed in this exercise:

\n\nDownload the base files for the app
\n\nAdd code to complete the web app
\n\nReview the overall code base
\n\nUpdate and run the deployment script
\n\nView and test the application

This exercise takes approximately **30** minutes to complete.

\n\nLaunch the Azure Cloud Shell and download the files

In this section of the exercise you download the a zipped file containing the base files for the app.

\n\nIn your browser navigate to the Azure portal [https://portal.azure.com](https://portal.azure.com); signing in with your Azure credentials if prompted.

\n\nUse the **[\>_]** button to the right of the search bar at the top of the page to create a new cloud shell in the Azure portal, selecting a **_Bash_** environment. The cloud shell provides a command line interface in a pane at the bottom of the Azure portal.

> **Note**: If you have previously created a cloud shell that uses a _PowerShell_ environment, switch it to **_Bash_**.

\n\nIn the cloud shell toolbar, in the **Settings** menu, select **Go to Classic version** (this is required to use the code editor).

\n\nRun the following commands in the **Bash** shell to create a project folder, and download and unzip the exercise files.

`\`bash

bash

mkdir voice-live-web && cd voice-live-web

`\`bash

text
text

`\`bash

bash

wget <https://github.com/MicrosoftLearning/mslearn-ai-language/raw/refs/heads/main/downloads/python/voice-live-web.zip>

`\`bash

text
text

`\`bash

text

unzip voice-live-web.zip

`\`bash

text
text

\n\nAdd code to complete the web app

Now that the exercise files are downloaded, the the next step is to add code to complete the application. The following steps are performed in the cloud shell.

> **Tip:** Resize the cloud shell to display more information, and code, by dragging the top border. You can also use the minimize and maximize buttons to switch between the cloud shell and the main portal interface.

Run the following command to change into the _src_ directory before you continue with the exercise.

`\`bash

bash

cd src

`\`bash

text
text

\n\nAdd code to implement the voice live assistant

In this section you add code to implement the voice live assistant. The **\_\_init\_\_** method initializes the voice assistant by storing the Azure VoiceLive connection parameters (endpoint, credentials, model, voice, and system instructions) and setting up runtime state variables to manage the connection lifecycle and handle user interruptions during conversations. The **start** method imports the necessary Azure VoiceLive SDK components that will be used to establish the WebSocket connection and configure the real-time voice session.

\n\nRun the following command to open the _flask_app.py_ file for editing.

`\`bash

bash

code flask_app.py

`\`bash

text
text

\n\nSearch for the **# BEGIN VOICE LIVE ASSISTANT IMPLEMENTATION - ALIGN CODE WITH COMMENT** comment in the code. Copy the code below and enter it just below the comment. Be sure to check the indentation.

`\`bash

python

def __init__(

```bash
self,
`\`bash

```bash
endpoint: str,
`\`bash

```bash
credential,
`\`bash

```bash
model: str,
`\`bash

```bash
voice: str,
`\`bash

```bash
instructions: str,
`\`bash

```bash
state_callback=None,
`\`bash

):

```bash
# Store Azure Voice Live connection and configuration parameters
`\`bash

```bash
self.endpoint = endpoint
`\`bash

```bash
self.credential = credential
`\`bash

```bash
self.model = model
`\`bash

```bash
self.voice = voice
`\`bash

```bash
self.instructions = instructions
`\`bash

```bash
# Initialize runtime state - connection established in start()
`\`bash

```bash
self.connection = None
`\`bash

```bash
self._response_cancelled = False  # Used to handle user interruptions
`\`bash

```bash
self._stopping = False  # Signals graceful shutdown
`\`bash

```bash
self.state_callback = state_callback or (lambda *_: None)
`\`bash

async def start(self):

```bash
# Import Voice Live SDK components needed for establishing connection and configuring session
`\`bash

```bash
from azure.ai.voicelive.aio import connect  # type: ignore
`\`bash

```bash
from azure.ai.voicelive.models import (
`\`bash

```bash
    RequestSession,
`\`bash

```bash
    ServerVad,
`\`bash

```bash
    AzureStandardVoice,
`\`bash

```bash
    Modality,
`\`bash

```bash
    InputAudioFormat,
`\`bash

```bash
    OutputAudioFormat,
`\`bash

```bash
)  # type: ignore
`\`bash

`\`bash

text
text

\n\nEnter **ctrl+s** to save your changes and keep the editor open for the next section.

\n\nAdd code to implement the voice live assistant

In this section you add code to configure the voice live session. This specifies the modalities (audio-only is not supported by the API), the system instructions that define the assistant's behavior, the Azure TTS voice for responses, the audio format for both input and output streams, and Server-side Voice Activity Detection (VAD) which specifies how the model detects when users start and stop speaking.

\n\nSearch for the **# BEGIN CONFIGURE VOICE LIVE SESSION - ALIGN CODE WITH COMMENT** comment in the code. Copy the code below and enter it just below the comment. Be sure to check the indentation.

`\`bash

python

# Configure VoiceLive session with audio/text modalities and voice activity detection

session_config = RequestSession(

```bash
modalities=[Modality.TEXT, Modality.AUDIO],
`\`bash

```bash
instructions=self.instructions,
`\`bash

```bash
voice=voice_cfg,
`\`bash

```bash
input_audio_format=InputAudioFormat.PCM16,
`\`bash

```bash
output_audio_format=OutputAudioFormat.PCM16,
`\`bash

```bash
turn_detection=ServerVad(threshold=0.5, prefix_padding_ms=300, silence_duration_ms=500),
`\`bash

)

await conn.session.update(session=session_config)

`\`bash

text
text

\n\nEnter **ctrl+s** to save your changes and keep the editor open for the next section.

\n\nAdd code to handle session events

In this section you add code to add event handlers for the voice live session. The event handlers respond to key VoiceLive session events during the conversation lifecycle: **\_handle_session_updated** signals when the session is ready for user input, **\_handle_speech_started** detects when the user begins speaking and implements interruption logic by stopping any ongoing assistant audio playback and canceling in-progress responses to allow natural conversation flow, and **\_handle_speech_stopped** handles when the user has finished speaking and the assistant begins processing the input.

\n\nSearch for the **# BEGIN HANDLE SESSION EVENTS - ALIGN CODE WITH COMMENT** comment in the code. Copy the code below and enter it just below the comment, be sure to check the indentation.

`\`bash

python

async def _handle_event(self, event, conn, verbose=False):

```bash
"""Handle Voice Live events with clear separation by event type."""
`\`bash

```bash
# Import event types for processing different Voice Live server events
`\`bash

```bash
from azure.ai.voicelive.models import ServerEventType
`\`bash

```bash
event_type = event.type
`\`bash

```bash
if verbose:
`\`bash

```bash
    _broadcast({"type": "log", "level": "debug", "event_type": str(event_type)})
`\`bash

```bash
# Route Voice Live server events to appropriate handlers
`\`bash

```bash
if event_type == ServerEventType.SESSION_UPDATED:
`\`bash

```bash
    await self._handle_session_updated()
`\`bash

```bash
elif event_type == ServerEventType.INPUT_AUDIO_BUFFER_SPEECH_STARTED:
`\`bash

```bash
    await self._handle_speech_started(conn)
`\`bash

```bash
elif event_type == ServerEventType.INPUT_AUDIO_BUFFER_SPEECH_STOPPED:
`\`bash

```bash
    await self._handle_speech_stopped()
`\`bash

```bash
elif event_type == ServerEventType.RESPONSE_AUDIO_DELTA:
`\`bash

```bash
    await self._handle_audio_delta(event)
`\`bash

```bash
elif event_type == ServerEventType.RESPONSE_AUDIO_DONE:
`\`bash

```bash
    await self._handle_audio_done()
`\`bash

```bash
elif event_type == ServerEventType.RESPONSE_DONE:
`\`bash

```bash
    # Reset cancellation flag but don't change state - _handle_audio_done already did
`\`bash

```bash
    self._response_cancelled = False
`\`bash

```bash
elif event_type == ServerEventType.ERROR:
`\`bash

```bash
    await self._handle_error(event)
`\`bash

async def _handle_session_updated(self):

```bash
"""Session is ready for conversation."""
`\`bash

```bash
self.state_callback("ready", "Session ready. You can start speaking now.")
`\`bash

async def _handle_speech_started(self, conn):

```bash
"""User started speaking - handle interruption if needed."""
`\`bash

```bash
self.state_callback("listening", "Listening… speak now")
`\`bash

```bash
try:
`\`bash

```bash
    # Stop any ongoing audio playback on the client side
`\`bash

```bash
    _broadcast({"type": "control", "action": "stop_playback"})
`\`bash

```bash
    # If assistant is currently speaking or processing, cancel the response to allow interruption
`\`bash

```bash
    current_state = assistant_state.get("state")
`\`bash

```bash
    if current_state in {"assistant_speaking", "processing"}:
`\`bash

```bash
        self._response_cancelled = True
`\`bash

```bash
        await conn.response.cancel()
`\`bash

```bash
        _broadcast({"type": "log", "level": "debug",
`\`bash

```bash
                  "msg": f"Interrupted assistant during {current_state}"})
`\`bash

```bash
    else:
`\`bash

```bash
        _broadcast({"type": "log", "level": "debug",
`\`bash

```bash
                  "msg": f"User speaking during {current_state} - no cancellation needed"})
`\`bash

```bash
except Exception as e:
`\`bash

```bash
    _broadcast({"type": "log", "level": "debug",
`\`bash

```bash
              "msg": f"Exception in speech handler: {e}"})
`\`bash

async def _handle_speech_stopped(self):

```bash
"""User stopped speaking - processing input."""
`\`bash

```bash
self.state_callback("processing", "Processing your input…")
`\`bash

async def _handle_audio_delta(self, event):

```bash
"""Stream assistant audio to clients."""
`\`bash

```bash
if self._response_cancelled:
`\`bash

```bash
    return  # Skip cancelled responses
`\`bash

```bash
# Update state when assistant starts speaking
`\`bash

```bash
if assistant_state.get("state") != "assistant_speaking":
`\`bash

```bash
    self.state_callback("assistant_speaking", "Assistant speaking…")
`\`bash

```bash
# Extract and broadcast Voice Live audio delta as base64 to WebSocket clients
`\`bash

```bash
audio_data = getattr(event, "delta", None)
`\`bash

```bash
if audio_data:
`\`bash

```bash
    audio_b64 = base64.b64encode(audio_data).decode("utf-8")
`\`bash

```bash
    _broadcast({"type": "audio", "audio": audio_b64})
`\`bash

async def _handle_audio_done(self):

```bash
"""Assistant finished speaking."""
`\`bash

```bash
self._response_cancelled = False
`\`bash

```bash
self.state_callback("ready", "Assistant finished. You can speak again.")
`\`bash

async def _handle_error(self, event):

```bash
"""Handle Voice Live errors."""
`\`bash

```bash
error = getattr(event, "error", None)
`\`bash

```bash
message = getattr(error, "message", "Unknown error") if error else "Unknown error"
`\`bash

```bash
self.state_callback("error", f"Error: {message}")
`\`bash

def request_stop(self):

```bash
self._stopping = True
`\`bash

`\`bash

text
text

\n\nEnter **ctrl+s** to save your changes and keep the editor open for the next section.

\n\nReview the code in the app

So far, you've added code to the app to implement the agent and handle agent events. Take a few minutes to review the full code and comments to get a better understanding of how the app is handling client state and operations.

\n\nWhen you're finished enter **ctrl+q** to exit out of the editor.

\n\nUpdate and run the deployment script

In this section you make a small change to the **azdeploy.sh** deployment script and then run the deployment.

\n\nUpdate the deployment script

There are only two values you should change at the top of the **azdeploy.sh** deployment script.

\n\nThe **rg** value specifies the resource group to contain the deployment. You can accept the default value, or enter your own value if you need to deploy to a specific resource group.

\n\nThe **location** value sets the region for the deployment. The _gpt-4o_ model used in the exercise can be deployed to other regions, but there can be limits in any particular region. If the deployment fails in your chosen region, try **eastus2** or **swedencentral**.

`\`bash

text

rg="rg-voicelive" # Replace with your resource group

location="eastus2" # Or a location near you

`\`bash

text
text

\n\nRun the following commands in the Cloud Shell to begin editing the deployment script.

`\`bash

bash

cd ~/voice-live-web

`\`bash

text
text

`\`bash

bash

code azdeploy.sh

`\`bash

text
text

\n\nUpdate the values for **rg** and **location** to meet your needs and then enter **ctrl+s** to save your changes and **ctrl+q** to exit the editor.

\n\nRun the deployment script

The deployment script deploys the AI model and creates the necessary resources in Azure to run a containerized app in App Service.

\n\nRun the following command in the Cloud Shell to begin deploying the Azure resources and the application.

`\`bash

bash

bash azdeploy.sh

`\`bash

text
text

\n\nSelect **option 1** for the initial deployment.

The deployment should complete in 5-10 minutes. During the deployment you might be prompted for the following information/actions:
\n\nIf you are prompted to authenticate to Azure follow the directions presented to you.
\n\nIf you are prompted to select a subscription use the arrow keys to highlight your subscription and press **Enter**.
\n\nYou will likely see some warnings during deployment and these can be ignored.
\n\nIf the deployment fails during the AI model deployment change the region in the deployment script and try again.
\n\nRegions in Azure can get busy at times and interrupt the timing of the deployments. If the deployment fails after the model deployment re-run the deployment script.

\n\nView and test the app

When the deployment completes a "Deployment complete!" message will be in the shell along with a link to the web app. You can select that link, or navigate to the App Service resource and launch the app from there. It can take a few minutes for the application to load.

\n\nSelect the **Start session** button to connect to the model.
\n\nYou will be prompted to give the application access to you audio devices.
\n\nBegin talking to the model when the app prompts you to start speaking.

Troubleshooting:

\n\nIf the app reports missing environment variables, restart the application in App Service.
\n\nIf you see excessive _audio chunk_ messages in the log shown in the application select **Stop session** and then start the session again.
\n\nIf the app fails to function at all, double-check you added all of the code and for proper indentation. If you need to make any changes re-run the deployment and select **option 2** to only update the image.

\n\nClean up resources

Run the following command in the Cloud Shell to remove all of the resources deployed for this exercise. You will be prompted to confirm the resource deletion.

`\`bash

text

azd down --purge

`\`bash

text
text

\n
