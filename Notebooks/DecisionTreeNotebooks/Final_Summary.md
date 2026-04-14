### Result

Brought the features of this dataset from 78 to *Final 4 selected features* and then applied PCA to reduce the dimensionality to 8. The final model is a Decision Tree Classifier with the following hyperparameters: `max_depth=18`, `min_samples_split=15`, `max_leaf_nodes=100`, and `criterion="gini"`. The model achieved an F1-score of 0.71 on the test set, which is a significant improvement compared to the baseline model that had an F1-score of 0.57.


Out main goal was to minimize False Negatives, so model depth of 10 and other hyperparameters same as above resulted in best model with lowes features to recall ration possible,

The final features are (These are based on the feature importance from the Decision Tree model):

```
"total fwd packets", "bwd packet length std", "avg packet size", "bwd packets/s"
```

The model is saved in Models folder of root directory as final_decision_tree_rf_model.pkl and can be used for inference.

### Additional Notes

- We also tried performing PCA on the top 20 and top 10 features, for comparision with feature elimination technique, but the results were not as good as the feature elimination technique. The PCA models had lower F1-scores compared to the model with selected features.