- Who is BondiFuzz for?
	- Developers, QA, and security teams working with:
		- Services with multiple back-end logic.​
		- Cross-platform software, like browsers, messengers, and office apps.
		- OS and firmware components for embedded devices.

- What makes it different?
	- It's easy to add new programming languages and fuzzing tools 
	- It does not require access to the product source code (but it might be necessary in some cases)
	- No requirements for specific solutions to ensure CI​

- How can BondiFuzz be integrated into the development process?
	- There are two options:
		- Integration with the client's CI system
		- Integration with a Bugtrack system
		A client may choose either option all both of them

- What is required for successful integration?
	- Depending on the chosen integration path:
		- If integration is not needed, you only need access to the web interface to upload fuzzing test suites and monitor results or install a CLI utility
		- For integration with a CI system:
			- the client has to automatically upload new versions of fuzzing test suites according to the product updates
		- For integration with a Bugtrack system:
			- grant automated access to the client's Bugtrack system (usually, this requires authorization data of a special account)
