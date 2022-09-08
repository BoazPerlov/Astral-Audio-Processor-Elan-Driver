# Astral-Audio-Processor-Elan-Driver
Driver for integrating the Focal Astral audio processor to Elan Home Automation platform

### Introduction
**[Astral](https://www.focal.com/uk/high-fidelity-speakers/audio-video-processor-and-amplifier/astral-16)** is a high end AV processor and amplifier supporting up to 16 channels of audio,  covering all audio formats such sa Dolby Atmos®, DTS:X™, Auro-3D® etc.

**[Elan](https://elancontrolsystems.com/)** is a home automation platform with an integration API. ELAN is the industry leader in smart home & business technology solutions.Integration of Akuvox intercoms via SIP-based communication is done via the intercom internal settings, and thus will not be outlined in this repository. The aim of this driver is to integrate Akuovox's relay control to Elan via the Elan driver development API. 

### How to Integrate
* Download the **Astral.EDRVC** file from this repository.
* In the Elan configurator, navigate to the Media tab, then the Zone Controllers node
* Right + Click **Zone Controllers** and **Add New Zone Controller**.
* In the list as shown below, click on the **Search Folder** button, navigate to the folder where the file was downloaded, then press ok.

![image](https://user-images.githubusercontent.com/50086268/189110729-1d51c259-1fef-4eaf-a12c-cc98b595a7ab.png)

* Highlight the Astral, then press OK.
* Add IP address

![image](https://user-images.githubusercontent.com/50086268/189110928-14d97946-6d6a-4cce-84a6-1ee1e8b84dbe.png)

* You'd be able to tell if connection was successful if the Brand, Model, Firmware Version populate automatically in their respective fields.

### Disclaimer
This is an unsupported driver which I wrote in my spare time. Neither Elan nor Indigo Distribution (Premium Elan Distributor in the UK and Ireland) hold any responsibilty or offer any support for the use of this driver in your Elan systems. By adding this driver you accept all risks associated with introducing a hastily written driver to your controller software; you do this at YOUR OWN RISK. And as ever: **ALWAYS BACKUP YOUR SYSTEM**
