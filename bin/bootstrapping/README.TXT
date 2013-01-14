
We want to use the bootstrapping technique to annotate a dataset of news.
	- we start with a dictionary of names extracted from Verbetes
	- we annotate the dataset of news with these names
	- we learn a CRF model with the annotated dataset
	- we test the model in the dataset of news
	- we use the novel identified names and annotate them on the news dataset
	- we use the enhanced annotated dataset and build a new CRF model
	- we test the model in the dataset of news
	- we identify the novel names and repeat this process until it stabilizes 	


1) Build a dataset of news (latest 20,000 news items from Voxx)
	* 1_build_dataset.pl >> dataset/news_dataset.txt
	
2) Build a dictionary with the most frequent names from Verbetes
	* 2_build_dictionary_names.pl >> dataset/dictionary_names_0.txt	
	
3) Annotate the dataset of news with the dictionary of names
	* 3_annotate_dataset_news.pl >> dataset/annotated_dataset_news_0.txt	
	
4) Convert annotated_dataset_news_0.txt onto a CRF structure
	* 4_convert_dataset_to_crf_structure.pl >> models/dataset_0.crf

5) Learn a CRF model based on the dataset 'dataset_0.crf'
	* 5_learn_model.pl >> models/0.model
	
6) Test dataset of news on the CRF model creates
	* 6_test_data.pl >> tests/test_0.txt
	
7) Identify new names test dataset output 'tests/test_0.txt'		 	
	* 7_identify_new_names_test_dataset.pl [tests/test_0.txt] >> dataset/dictionary_new_names_1.txt	
	
8) Prepare a sample of the test dataset to manually evaluate	
	* 8_prepare_sample_test.pl [tests/test_1.txt] > evaluation/sample_test_1.txt
	
9) Evaluate the dictionary of new names
	* 9_evaluate_sample_new_names [dataset/dictionary_new_names_1.txt] >> evaluation/sample_new_names_1.txt	
	
----> new cycle (nr of the cycle: CYCLE)

3C) Annotate the previously annotated dataset of news (dataset/annotated_dataset_news_CYCLE.txt) 
		with the dictionary of new names (dataset/dictionary_new_names_CYCLE.txt)
	* 3C_annotate_dataset_news_cycle.pl [CYCLE] >> dataset/annotated_dataset_news_CYCLE.txt	
 	
4C) Convert 'dataset/annotated_dataset_news_CYCLE.txt' onto a CRF structure
	* 4C_convert_dataset_to_crf_structure_cycle.pl [CYCLE] >> models/dataset_CYCLE.crf
	
5C) Learn a CRF model based on the dataset 'dataset_[CYCLE].crf'
	* 5C_learn_model_cycle.pl [CYCLE] >> models/[CYCLE].model
	
6C) Test dataset of news on the CRF model creates
	* 6C_test_data_cycle.pl [CYCLE] >> tests/test_[CYCLE].txt
	
7C) Identify new names
	* 7C_identify_new_names_test_dataset.pl [CYCLE] >> dataset/dictionary_new_names_CYCLE.txt
													> logs/iteration_CYCLE.log  			
	