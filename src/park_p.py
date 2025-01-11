

    for feature in vector_layer.getFeatures():
        # Get the geometry of the point
        point = feature.geometry().asPoint()

        # Transform the point if layers have different CRS
        raster_crs = raster_layer.crs()
        vector_crs = vector_layer.crs()
        if raster_crs != vector_crs:
            transform_context = QgsProject.instance().transformContext()
            transform = QgsCoordinateTransform(vector_crs, raster_crs, transform_context)
            point = transform.transform(point)

        # Get raster value at the point
        value = raster_data_provider.sample(point, 1)
        if value[1] is not None:  # If a value is found
            feature["RasterValue"] = value[1]
            vector_layer.updateFeature(feature)


# Save the updated shapefile
vector_layer.commitChanges()
vector_layer_provider.createSpatialIndex()
vector_layer.dataProvider().createSpatialIndex()